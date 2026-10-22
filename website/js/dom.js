/** Tiny DOM helpers. No framework, no virtual DOM, no globals. */

export function el(tag, props = {}, ...children) {
  const node = document.createElement(tag);
  if (props && typeof props === 'object') {
    Object.entries(props).forEach(([key, value]) => {
      if (value == null || value === false) return;
      if (key === 'class') node.className = value;
      else if (key === 'dataset') Object.assign(node.dataset, value);
      else if (key === 'style' && typeof value === 'object') Object.assign(node.style, value);
      else if (key === 'text') node.textContent = value;
      else if (key === 'html') node.innerHTML = value;
      else if (key === 'on' && typeof value === 'object') {
        Object.entries(value).forEach(([event, handler]) => node.addEventListener(event, handler));
      } else if (key.startsWith('on') && typeof value === 'function') {
        node.addEventListener(key.slice(2).toLowerCase(), value);
      } else if (value === true) node.setAttribute(key, '');
      else node.setAttribute(key, String(value));
    });
  }
  append(node, ...children);
  return node;
}

export function append(parent, ...children) {
  children.flat(Infinity).forEach((child) => {
    if (child == null || child === false) return;
    parent.appendChild(child instanceof Node ? child : document.createTextNode(String(child)));
  });
  return parent;
}

export function clear(node) {
  while (node.firstChild) node.removeChild(node.firstChild);
  return node;
}

export function replace(node, ...children) {
  clear(node);
  append(node, ...children);
  return node;
}

export function svgFromString(markup) {
  const template = document.createElement('template');
  template.innerHTML = markup.trim();
  return template.content.firstElementChild;
}

export function qs(selector, root = document) {
  return root.querySelector(selector);
}

export function qsa(selector, root = document) {
  return [...root.querySelectorAll(selector)];
}

export function on(target, event, handler, options) {
  target.addEventListener(event, handler, options);
  return () => target.removeEventListener(event, handler, options);
}

const FOCUSABLE = 'a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])';

export function focusables(root) {
  return qsa(FOCUSABLE, root).filter((node) => node.offsetParent !== null || node === document.activeElement);
}

/** Keeps focus inside a dialog and returns the restore function. */
export function trapFocus(root, initialFocus) {
  const previouslyFocused = document.activeElement;
  const focusTarget = initialFocus || focusables(root)[0] || root;
  requestAnimationFrame(() => {
    try {
      focusTarget.focus({ preventScroll: true });
    } catch {
      /* focus can fail on inert elements */
    }
  });

  const onKeyDown = (event) => {
    if (event.key !== 'Tab') return;
    const items = focusables(root);
    if (items.length === 0) {
      event.preventDefault();
      return;
    }
    const first = items[0];
    const last = items[items.length - 1];
    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault();
      last.focus();
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault();
      first.focus();
    }
  };
  root.addEventListener('keydown', onKeyDown);

  return () => {
    root.removeEventListener('keydown', onKeyDown);
    if (previouslyFocused && typeof previouslyFocused.focus === 'function') {
      try {
        previouslyFocused.focus({ preventScroll: true });
      } catch {
        /* best effort */
      }
    }
  };
}
