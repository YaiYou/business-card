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
            celebrate();
        }
    }, 1000);
}

button.addEventListener("click", () => startCountdown(10));

// Show the full ring at rest.
render(0, 0);
progress.style.strokeDashoffset = 0;

/* ---------------------------------------------------------------------------
   Celebration: confetti + streamers, rendered on a full-screen canvas.
   Fired once the countdown reaches zero.
--------------------------------------------------------------------------- */

const CELEBRATION_COLORS = [
    "#f94144", "#f3722c", "#f8961e", "#f9c74f",
    "#90be6d", "#43aa8b", "#4d96ff", "#577590",
    "#e56399", "#9b5de5", "#00bbf9", "#f15bb5",
];

function rand(min, max) {
    return min + Math.random() * (max - min);
}

function pick(list) {
    return list[Math.floor(Math.random() * list.length)];
}

function celebrate() {
    const canvas = document.querySelector(".confetti-canvas");
    const ctx = canvas.getContext("2d");

    function resize() {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
    }
    resize();
    window.addEventListener("resize", resize);

    const gravity = 0.12;
    const pieces = [];

    // Confetti: small spinning rectangles that flutter as they fall.
    for (let i = 0; i < 160; i++) {
        pieces.push({
            type: "confetti",
            x: rand(0, canvas.width),
            y: rand(-canvas.height * 0.6, -10),
            w: rand(6, 12),
            h: rand(8, 16),
            color: pick(CELEBRATION_COLORS),
            vx: rand(-2, 2),
            vy: rand(1.5, 4),
            rot: rand(0, Math.PI * 2),
            vrot: rand(-0.25, 0.25),
            sway: rand(0, Math.PI * 2),
            swaySpeed: rand(0.02, 0.06),
        });
    }

    // Streamers: long wavy ribbons that drift down more slowly.
    for (let i = 0; i < 28; i++) {
        pieces.push({
            type: "streamer",
            x: rand(0, canvas.width),
            y: rand(-canvas.height * 0.8, -40),
            len: rand(50, 110),
            color: pick(CELEBRATION_COLORS),
            vx: rand(-1.2, 1.2),
            vy: rand(1, 2.4),
            phase: rand(0, Math.PI * 2),
            waveAmp: rand(6, 12),
            waveFreq: rand(0.08, 0.16),
            sway: rand(0, Math.PI * 2),
            swaySpeed: rand(0.015, 0.04),
            swayAmp: rand(0.6, 1.6),
        });
    }

    let frameId = null;

    function drawConfetti(p) {
        p.vy += gravity;
        p.sway += p.swaySpeed;
        p.x += p.vx + Math.sin(p.sway) * 0.6;
        p.y += p.vy;
        p.rot += p.vrot;

        ctx.save();
        ctx.translate(p.x, p.y);
        ctx.rotate(p.rot);
        ctx.fillStyle = p.color;
        // Squash horizontally as it spins so it reads like a flat flake.
        const squash = Math.abs(Math.cos(p.sway));
        ctx.fillRect(-p.w / 2, -p.h / 2, p.w * (0.4 + 0.6 * squash), p.h);
        ctx.restore();
    }

    function drawStreamer(p) {
        p.vy += gravity * 0.4;
        p.sway += p.swaySpeed;
        p.x += p.vx + Math.sin(p.sway) * p.swayAmp;
        p.y += p.vy;

        ctx.strokeStyle = p.color;
        ctx.lineWidth = 5;
        ctx.lineCap = "round";
        ctx.beginPath();
        for (let s = 0; s <= p.len; s += 5) {
            const xx = p.x + Math.sin(s * p.waveFreq + p.phase + p.sway) * p.waveAmp;
            const yy = p.y + s;
            if (s === 0) ctx.moveTo(xx, yy);
            else ctx.lineTo(xx, yy);
        }
        ctx.stroke();
    }

    function frame() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        let alive = 0;

        for (const p of pieces) {
            if (p.type === "confetti") drawConfetti(p);
            else drawStreamer(p);

            const tail = p.type === "streamer" ? p.len : p.h;
            if (p.y - tail < canvas.height + 40) alive++;
        }

        if (alive > 0) {
            frameId = requestAnimationFrame(frame);
        } else {
            cancelAnimationFrame(frameId);
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            window.removeEventListener("resize", resize);
        }
    }

    frame();
}
