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

// How long the cannons keep firing, in milliseconds.
const CELEBRATION_EMIT_MS = 3000;
const GRAVITY = 0.35;
const DRAG = 0.992;
// Launch angle above horizontal for each cannon (70°).
const LAUNCH_ANGLE = (70 * Math.PI) / 180;

function celebrate() {
    const canvas = document.querySelector(".confetti-canvas");
    const ctx = canvas.getContext("2d");

    function resize() {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
    }
    resize();
    window.addEventListener("resize", resize);

    const pieces = [];
    let startTime = null;
    let frameId = null;

    // Two cannons in the lower corners, each firing up and inward at ~45°.
    function cannons() {
        return [
            { x: 0, y: canvas.height, dir: 1 },              // bottom-left  -> up-right
            { x: canvas.width, y: canvas.height, dir: -1 },  // bottom-right -> up-left
        ];
    }

    function emit() {
        for (const c of cannons()) {
            // A dense stream of confetti.
            for (let i = 0; i < 5; i++) {
                const angle = rand(LAUNCH_ANGLE - 0.18, LAUNCH_ANGLE + 0.18);
                const speed = rand(15, 30);
                pieces.push({
                    type: "confetti",
                    x: c.x,
                    y: c.y,
                    vx: c.dir * Math.cos(angle) * speed,
                    vy: -Math.sin(angle) * speed,
                    w: rand(6, 14),
                    h: rand(8, 17),
                    color: pick(CELEBRATION_COLORS),
                    rot: rand(0, Math.PI * 2),
                    vrot: rand(-0.35, 0.35),
                    sway: rand(0, Math.PI * 2),
                    swaySpeed: rand(0.03, 0.09),
                });
            }
            // Streamers fired alongside, trailing ribbons behind them.
            if (Math.random() < 0.55) {
                const angle = rand(LAUNCH_ANGLE - 0.15, LAUNCH_ANGLE + 0.15);
                const speed = rand(16, 27);
                pieces.push({
                    type: "streamer",
                    x: c.x,
                    y: c.y,
                    vx: c.dir * Math.cos(angle) * speed,
                    vy: -Math.sin(angle) * speed,
                    len: rand(45, 105),
                    color: pick(CELEBRATION_COLORS),
                    phase: rand(0, Math.PI * 2),
                    waveAmp: rand(5, 12),
                    waveFreq: rand(0.1, 0.18),
                    wave: rand(0, Math.PI * 2),
                    waveSpeed: rand(0.15, 0.3),
                });
            }
        }
    }

    function drawConfetti(p) {
        p.vy += GRAVITY;
        p.vx *= DRAG;
        p.sway += p.swaySpeed;
        p.x += p.vx;
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
        p.vy += GRAVITY * 0.5;
        p.vx *= DRAG;
        p.x += p.vx;
        p.y += p.vy;
        p.wave += p.waveSpeed;

        // Trail the ribbon behind the head, along the reverse of its heading.
        const speed = Math.hypot(p.vx, p.vy) || 1;
        const ux = p.vx / speed;
        const uy = p.vy / speed;
        const perpX = -uy;
        const perpY = ux;

        ctx.strokeStyle = p.color;
        ctx.lineWidth = 5;
        ctx.lineCap = "round";
        ctx.beginPath();
        for (let s = 0; s <= p.len; s += 5) {
            const wobble = Math.sin(s * p.waveFreq + p.phase + p.wave) * p.waveAmp;
            const xx = p.x - ux * s + perpX * wobble;
            const yy = p.y - uy * s + perpY * wobble;
            if (s === 0) ctx.moveTo(xx, yy);
            else ctx.lineTo(xx, yy);
        }
        ctx.stroke();
    }

    function frame(now) {
        if (startTime === null) startTime = now;
        const elapsed = now - startTime;

        ctx.clearRect(0, 0, canvas.width, canvas.height);

        if (elapsed < CELEBRATION_EMIT_MS) emit();

        let alive = 0;
        for (const p of pieces) {
            if (p.type === "confetti") drawConfetti(p);
            else drawStreamer(p);

            const tail = p.type === "streamer" ? p.len : p.h;
            if (p.y - tail < canvas.height + 60) alive++;
        }

        if (elapsed < CELEBRATION_EMIT_MS || alive > 0) {
            frameId = requestAnimationFrame(frame);
        } else {
            cancelAnimationFrame(frameId);
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            window.removeEventListener("resize", resize);
        }
    }

    frameId = requestAnimationFrame(frame);
}
