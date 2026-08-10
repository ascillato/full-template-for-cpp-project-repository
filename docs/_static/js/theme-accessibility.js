"use strict";

(() => {
  try {
    const storedTheme = window.localStorage.getItem("theme");
    if (storedTheme === "dark" || storedTheme === "light") {
      document.documentElement.setAttribute("data-theme", storedTheme);
    }
  } catch {
    // Storage can be unavailable; leave the theme extension's default behavior intact.
  }

  const updateThemeButton = () => {
    const button = document.getElementById("themeSwitcher");
    if (!button) {
      return;
    }

    const darkMode = document.documentElement.getAttribute("data-theme") === "dark";
    const label = darkMode ? "Use light theme" : "Use dark theme";
    button.type = "button";
    button.setAttribute("aria-label", label);
    button.setAttribute("aria-pressed", String(darkMode));
    button.setAttribute("title", label);
    button.querySelectorAll("i").forEach((icon) => icon.setAttribute("aria-hidden", "true"));
  };

  const initializeThemeAccessibility = () => {
    new MutationObserver(updateThemeButton).observe(document.documentElement, {
      attributeFilter: ["data-theme"],
      attributes: true,
    });

    if (document.getElementById("themeSwitcher")) {
      updateThemeButton();
      return;
    }

    const buttonObserver = new MutationObserver(() => {
      if (document.getElementById("themeSwitcher")) {
        updateThemeButton();
        buttonObserver.disconnect();
      }
    });
    buttonObserver.observe(document.body, { childList: true, subtree: true });
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initializeThemeAccessibility, { once: true });
  } else {
    initializeThemeAccessibility();
  }
})();
