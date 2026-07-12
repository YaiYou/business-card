const RADIUS = 90;
const CIRCUMFERENCE = 2 * Math.PI * RADIUS;

const progress = document.querySelector(".timer-ring-progress");
const display = document.querySelector(".timer-display");
const button = document.querySelector(".timer-button");

let intervalId = null;

function render(remaining, total) {
    display.textContent = remaining;
    // As remaining shrinks, hide more of the ring by increasing the dash offset.
    const fraction = total > 0 ? remaining / total : 0;
    progress.style.strokeDashoffset = CIRCUMFERENCE * (1 - fraction);
}

function startCountdown(seconds) {
    if (intervalId !== null) {
        clearInterval(intervalId);
    }

    let remaining = seconds;
    button.disabled = true;
    render(remaining, seconds);

    intervalId = setInterval(() => {
        remaining -= 1;
        render(remaining, seconds);

        if (remaining <= 0) {
            clearInterval(intervalId);
            intervalId = null;
            button.disabled = false;
        }
    }, 1000);
}

button.addEventListener("click", () => startCountdown(10));

// Show the full ring at rest.
render(0, 0);
progress.style.strokeDashoffset = 0;
