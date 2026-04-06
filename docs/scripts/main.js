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
    await loadStep("intro", "steps/intro.html");
    await loadStep("step1", "steps/step1.html");
    await loadStep("step2", "steps/step2.html");
    await loadStep("step3", "steps/step3.html");
    await loadStep("step4", "steps/step4.html");
    await loadStep("step5", "steps/step5.html");
    await loadStep("step6", "steps/step6.html");
    await loadStep("step7", "steps/step7.html");
    await loadStep("step8", "steps/step8.html");
    await loadStep("implementation", "steps/implementation.html");
    await loadStep("conclusion", "steps/conclusion.html");

    window.dispatchEvent(new Event("stepsLoaded"));
});