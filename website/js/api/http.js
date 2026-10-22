/**
 * HTTP layer: timeout, bounded retries for transient failures only, and
 * explicit error kinds the UI can translate. Malformed JSON is never retried.
 */
import { NET } from '../config.js';

export class ApiError extends Error {
  constructor(kind, message, { status = 0, url = '', retryable = false, cause = null } = {}) {
    super(message, { cause });
    this.name = 'ApiError';
    this.kind = kind;
    this.status = status;
    this.url = url;
    this.retryable = retryable;
  }
}

const RETRYABLE_KINDS = new Set(['timeout', 'network', 'server']);

export function isTransient(error) {
  return error instanceof ApiError && RETRYABLE_KINDS.has(error.kind) && error.retryable;
}

function delay(ms, signal) {
  return new Promise((resolve, reject) => {
    if (signal?.aborted) {
      reject(new DOMException('Aborted', 'AbortError'));
      return;
    }
    const timer = setTimeout(resolve, ms);
    signal?.addEventListener('abort', () => {
      clearTimeout(timer);
      reject(new DOMException('Aborted', 'AbortError'));
    }, { once: true });
  });
}

async function requestOnce(url, { timeout, signal }) {
  const controller = new AbortController();
  let timedOut = false;
  const timer = setTimeout(() => {
    timedOut = true;
    controller.abort();
  }, timeout);

  const forwardAbort = () => controller.abort();
  signal?.addEventListener('abort', forwardAbort, { once: true });

  try {
    let response;
    try {
      response = await fetch(url, {
        method: 'GET',
        mode: 'cors',
        credentials: 'omit',
        cache: 'default',
        headers: { Accept: 'application/json' },
        signal: controller.signal,
      });
    } catch (error) {
      if (signal?.aborted) throw new ApiError('abort', 'Request aborted', { url });
      if (timedOut) throw new ApiError('timeout', 'Request timed out', { url, retryable: true, cause: error });
      throw new ApiError('network', 'Network request failed', { url, retryable: true, cause: error });
    }

    if (!response.ok) {
      const retryable = response.status === 429 || response.status >= 500;
      throw new ApiError(retryable ? 'server' : 'http', `HTTP ${response.status}`, {
        status: response.status,
        url,
        retryable,
      });
    }

    let text;
    try {
      text = await response.text();
    } catch (error) {
      if (timedOut || signal?.aborted) throw new ApiError('timeout', 'Response timed out', { url, retryable: true });
      throw new ApiError('network', 'Could not read the response', { url, retryable: true, cause: error });
    }

    try {
      return JSON.parse(text);
    } catch (error) {
      throw new ApiError('data', 'Invalid JSON payload', { url, retryable: false, cause: error });
    }
  } finally {
    clearTimeout(timer);
    signal?.removeEventListener('abort', forwardAbort);
  }
}

export async function getJSON(url, { timeout = NET.timeoutMs, retries = NET.retries, signal } = {}) {
  let attempt = 0;
  for (;;) {
    try {
      return await requestOnce(url, { timeout, signal });
    } catch (error) {
      const transient = isTransient(error);
      if (!transient || attempt >= retries) throw error;
      attempt += 1;
      await delay(NET.retryDelayMs * attempt, signal);
    }
  }
}

export function buildUrl(base, params) {
  const url = new URL(base);
  Object.entries(params).forEach(([key, value]) => {
    if (value == null) return;
    url.searchParams.set(key, String(value));
  });
  return url.toString();
}
