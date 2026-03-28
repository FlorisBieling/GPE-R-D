async function loadStep(targetId, filePath) {
    const target = document.getElementById(targetId);

    if (!target) {
        return;
    }

    try {
        const response = await fetch(filePath);

        if (!response.ok) {
            target.innerHTML = `<div class="step-card"><p>Failed to load ${filePath}</p></div>`;
            return;
        }

        const html = await response.text();
        target.innerHTML = html;
    } catch {
        target.innerHTML = `<div class="step-card"><p>Failed to load ${filePath}</p></div>`;
    }
}

window.addEventListener("DOMContentLoaded", async () => {
    await loadStep("step1", "steps/step1.html");
    await loadStep("step2", "steps/step2.html");
    await loadStep("step3", "steps/step3.html");

    window.dispatchEvent(new Event("stepsLoaded"));
});