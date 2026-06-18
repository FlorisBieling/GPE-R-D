"use strict";

async function loadFragment(slot) {
  const path = slot.dataset.fragment;
  slot.innerHTML = '<div class="loading-card">Loading section…</div>';

  try {
    const response = await fetch(path);

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    slot.innerHTML = await response.text();
  } catch (error) {
    slot.innerHTML = `
      <div class="error-card">
        <strong>Could not load ${path}</strong>
        <p>Open this site through GitHub Pages or a local web server. HTML fragments cannot be fetched reliably from a file:// URL.</p>
      </div>
    `;
    console.error(`Failed to load ${path}`, error);
  }
}

function initializeProjectImages(root = document) {
  root.querySelectorAll(".project-image[data-src]").forEach((container) => {
    if (container.dataset.initialized === "true") {
      return;
    }

    container.dataset.initialized = "true";
    const image = new Image();
    image.loading = "lazy";
    image.decoding = "async";
    image.alt = container.dataset.alt || "Project image";

    image.addEventListener("load", () => {
      container.replaceChildren(image);
    });

    image.src = container.dataset.src;
  });
}

function initializeCodeCopyButtons(root = document) {
  root.querySelectorAll(".code-block").forEach((block) => {
    if (block.querySelector(".copy-code-button")) {
      return;
    }

    const code = block.querySelector("code");
    if (!code) {
      return;
    }

    const button = document.createElement("button");
    button.type = "button";
    button.className = "copy-code-button";
    button.textContent = "Copy";

    button.addEventListener("click", async () => {
      try {
        await navigator.clipboard.writeText(code.textContent);
        button.textContent = "Copied";
        window.setTimeout(() => {
          button.textContent = "Copy";
        }, 1400);
      } catch {
        button.textContent = "Copy failed";
      }
    });

    block.appendChild(button);
  });
}

function initializeSectionControls() {
  const expandButton = document.getElementById("expandAllButton");
  const collapseButton = document.getElementById("collapseAllButton");

  expandButton?.addEventListener("click", () => {
    document.querySelectorAll(".step-wrapper").forEach((details) => {
      details.open = true;
    });
  });

  collapseButton?.addEventListener("click", () => {
    document.querySelectorAll(".step-wrapper").forEach((details) => {
      details.open = false;
    });
  });
}

function initializeNavigation() {
  const menuButton = document.querySelector(".mobile-menu-button");
  const navigation = document.getElementById("site-navigation");

  menuButton?.addEventListener("click", () => {
    const isOpen = navigation.classList.toggle("is-open");
    menuButton.setAttribute("aria-expanded", String(isOpen));
  });

  navigation?.querySelectorAll("a").forEach((link) => {
    link.addEventListener("click", () => {
      navigation.classList.remove("is-open");
      menuButton?.setAttribute("aria-expanded", "false");
    });
  });

  const trackedLinks = Array.from(document.querySelectorAll('.table-of-contents a[href^="#"], .site-navigation a[href^="#"]'));
  const sections = Array.from(document.querySelectorAll("main section[id]")).filter((section) => section.id !== "top");

  if (!("IntersectionObserver" in window)) {
    return;
  }

  const observer = new IntersectionObserver((entries) => {
    const visible = entries
      .filter((entry) => entry.isIntersecting)
      .sort((a, b) => b.intersectionRatio - a.intersectionRatio)[0];

    if (!visible) {
      return;
    }

    trackedLinks.forEach((link) => {
      const active = link.getAttribute("href") === `#${visible.target.id}`;
      if (active) {
        link.setAttribute("aria-current", "true");
      } else {
        link.removeAttribute("aria-current");
      }
    });
  }, {
    rootMargin: "-18% 0px -68% 0px",
    threshold: [0, 0.1, 0.3]
  });

  sections.forEach((section) => observer.observe(section));
}

window.addEventListener("DOMContentLoaded", async () => {
  const slots = Array.from(document.querySelectorAll("[data-fragment]"));
  await Promise.all(slots.map(loadFragment));

  initializeProjectImages();
  initializeCodeCopyButtons();
  initializeSectionControls();
  initializeNavigation();

  window.dispatchEvent(new CustomEvent("terrain:content-ready"));
});
