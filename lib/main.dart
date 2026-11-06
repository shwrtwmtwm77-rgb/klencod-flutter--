import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Neon Nebula Striker - لعبة حرب الفضاء</title>
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Font Awesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Google Font (Tajawal & Press Start 2P for Arcade style) -->
    <link href="https://fonts.googleapis.com/css2?family=Press+Start+2P&family=Tajawal:wght@400;700;900&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Tajawal', sans-serif;
            background-color: #090a0f;
            color: #fff;
            overflow: hidden;
            user-select: none;
            -webkit-user-select: none;
        }
        .arcade-font {
            font-family: 'Press Start 2P', monospace;
        }
        #gameCanvas {
            background: radial-gradient(circle at center, #111428 0%, #050608 100%);
            box-shadow: 0 0 30px rgba(0, 240, 255, 0.2);
        }
        .glow-text-cyan {
            text-shadow: 0 0 10px rgba(0, 243, 255, 0.8), 0 0 20px rgba(0, 243, 255, 0.4);
        }
        .glow-text-pink {
            text-shadow: 0 0 10px rgba(255, 0, 127, 0.8), 0 0 20px rgba(255, 0, 127, 0.4);
        }
        /* Custom UI Buttons */
        .arcade-btn {
            background: linear-gradient(135deg, #ff007f 0%, #7928ca 100%);
            transition: all 0.2s ease;
            box-shadow: 0 0 15px rgba(255, 0, 127, 0.4);
        }
        .arcade-btn:hover {
            transform: translateY(-2px) scale(1.02);
            box-shadow: 0 0 25px rgba(255, 0, 127, 0.7);
        }
        .arcade-btn:active {
            transform: translateY(1px);
        }
    </style>
</head>
<body class="flex flex-col items-center justify-center min-h-screen m-0 p-0 relative">

    <!-- Container for Canvas and UI -->
    <div class="relative w-full max-w-4xl h-[100vh] sm:h-[90vh] flex flex-col justify-center items-center p-2">

        <!-- Header / HUD Panel -->
        <div class="w-full max-w-2xl flex justify-between items-center bg-gray-900/80 backdrop-blur-md border border-cyan-500/30 rounded-t-xl px-6 py-3 text-sm sm:text-base z-10">
            <div class="flex items-center gap-4">
                <div class="flex items-center gap-2">
                    <i class="fas fa-trophy text-yellow-400"></i>
                    <span class="text-gray-400">النقاط:</span>
                    <span id="scoreText" class="arcade-font text-cyan-400 font-bold text-lg">0</span>
                </div>
                <div class="flex items-center gap-2">
                    <i class="fas fa-fire text-orange-500"></i>
                    <span class="text-gray-400">المضاعف:</span>
                    <span id="multiplierText" class="arcade-font text-yellow-400 font-bold">x1</span>
                </div>
            </div>
            
            <div class="flex items-center gap-6">
                <!-- Health Bar -->
                <div class="flex items-center gap-2">
                    <i class="fas fa-heart text-red-500"></i>
                    <div class="w-24 sm:w-32 bg-gray-700 h-3 rounded-full overflow-hidden border border-gray-600">
                        <div id="healthBar" class="bg-gradient-to-r from-red-500 to-emerald-400 h-full w-full transition-all duration-300"></div>
                    </div>
                </div>

                <!-- Mute Button -->
                <button id="soundToggleBtn" class="text-gray-400 hover:text-white transition focus:outline-none">
                    <i id="soundIcon" class="fas fa-volume-up text-lg"></i>
                </button>
            </div>
        </div>

        <!-- Main Canvas Area -->
        <div class="relative w-full max-w-2xl flex-1 flex items-center justify-center overflow-hidden border-x border-b border-cyan-500/30 rounded-b-xl">
            <canvas id="gameCanvas" class="w-full h-full block rounded-b-xl"></canvas>

            <!-- Start / Game Over Screen Overlay -->
            <div id="overlayScreen" class="absolute inset-0 bg-black/80 backdrop-blur-md flex flex-col justify-center items-center p-6 text-center z-20 transition-opacity duration-300">
                <h1 id="overlayTitle" class="text-3xl sm:text-5xl font-extrabold mb-2 glow-text-cyan tracking-wider">NEON STRIKER</h1>
                <p id="overlaySubtitle" class="text-gray-300 mb-8 max-w-md text-sm sm:text-base">دمر أسطول الأعداء الفضائي، اجمع التطويرات وحقق أعلى نتيجة ممكنة!</p>
                
                <!-- Stats Showcase on Game Over -->
                <div id="statsBox" class="hidden mb-6 bg-gray-800/60 p-4 rounded-lg border border-gray-700 w-64 text-right">
                    <div class="flex justify-between my-1">
                        <span class="text-gray-400">النتيجة النهائية:</span>
                        <span id="finalScore" class="arcade-font text-cyan-400">0</span>
                    </div>
                    <div class="flex justify-between my-1">
                        <span class="text-gray-400">الأعداء المدمَرين:</span>
                        <span id="finalKills" class="arcade-font text-pink-400">0</span>
                    </div>
                    <div class="flex justify-between my-1">
                        <span class="text-gray-400">أعلى نتيجة:</span>
                        <span id="highScore" class="arcade-font text-yellow-400">0</span>
                    </div>
                </div>

                <!-- Controls Guide -->
                <div class="mb-8 text-xs text-gray-400 bg-gray-900/50 p-3 rounded-lg border border-gray-800 max-w-xs">
                    <div class="font-bold text-gray-300 mb-1">التحكم:</div>
                    <p>⬅️ ➡️ أو A/D للتحريك الأفقي</p>
                    <p>⬆️ ⬇️ أو W/S للتحريك العمودي</p>
                    <p>المسافة (Space) لإطلاق النار تلقائياً / لمس الشاشة على الجوال</p>
                </div>

                <button id="startBtn" class="arcade-btn px-8 py-4 rounded-full font-bold text-lg text-white uppercase tracking-wider flex items-center gap-3 cursor-pointer">
                    <i class="fas fa-play"></i>
                    <span id="btnText">ابدأ اللعب الآن</span>
                </button>
            </div>
        </div>

        <!-- Mobile Touch Controls overlay (shown only on mobile) -->
        <div id="touchControls" class="w-full max-w-2xl flex justify-between items-center mt-3 px-4 sm:hidden">
            <div class="grid grid-cols-3 gap-2 w-36">
                <div></div>
                <button id="btnUp" class="bg-gray-800/80 active:bg-cyan-600 text-white p-4 rounded-lg flex items-center justify-center text-xl shadow"><i class="fas fa-arrow-up"></i></button>
                <div></div>
                <button id="btnLeft" class="bg-gray-800/80 active:bg-cyan-600 text-white p-4 rounded-lg flex items-center justify-center text-xl shadow"><i class="fas fa-arrow-left"></i></button>
                <button id="btnDown" class="bg-gray-800/80 active:bg-cyan-600 text-white p-4 rounded-lg flex items-center justify-center text-xl shadow"><i class="fas fa-arrow-down"></i></button>
                <button id="btnRight" class="bg-gray-800/80 active:bg-cyan-600 text-white p-4 rounded-lg flex items-center justify-center text-xl shadow"><i class="fas fa-arrow-right"></i></button>
            </div>
            <button id="btnShoot" class="bg-red-600/80 active:bg-red-500 text-white w-24 h-24 rounded-full flex items-center justify-center text-2xl font-bold shadow-lg border-2 border-red-400">
                <i class="fas fa-crosshairs"></i>
            </button>
        </div>

    </div>

    <!-- Game Logic Script -->
    <script>
        // --- Web Audio API Synth Engine ---
        class SoundEngine {
            constructor() {
                this.ctx = null;
                this.muted = false;
            }

            init() {
                if (!this.ctx) {
                    const AudioContext = window.AudioContext || window.webkitAudioContext;
                    this.ctx = new AudioContext();
                }
            }

            playShoot() {
                if (this.muted || !this.ctx) return;
                const osc = this.ctx.createOscillator();
                const gain = this.ctx.createGain();
                osc.type = 'sawtooth';
                osc.frequency.setValueAtTime(800, this.ctx.currentTime);
                osc.frequency.exponentialRampToValueAtTime(100, this.ctx.currentTime + 0.15);
                gain.gain.setValueAtTime(0.15, this.ctx.currentTime);
                gain.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.15);
                osc.connect(gain);
                gain.connect(this.ctx.destination);
                osc.start();
                osc.stop(this.ctx.currentTime + 0.15);
            }

            playExplosion() {
                if (this.muted || !this.ctx) return;
                // Noise buffer generation
                const bufferSize = this.ctx.sampleRate * 0.3;
                const buffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
                const data = buffer.getChannelData(0);
                for (let i = 0; i < bufferSize; i++) {
                    data[i] = Math.random() * 2 - 1;
                }
                const noise = this.ctx.createBufferSource();
                noise.buffer = buffer;

                const filter = this.ctx.createBiquadFilter();
                filter.type = 'lowpass';
                filter.frequency.setValueAtTime(1000, this.ctx.currentTime);
                filter.frequency.linearRampToValueAtTime(100, this.ctx.currentTime + 0.3);

                const gain = this.ctx.createGain();
                gain.gain.setValueAtTime(0.3, this.ctx.currentTime);
                gain.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.3);

                noise.connect(filter);
                filter.connect(gain);
                gain.connect(this.ctx.destination);

                noise.start();
                noise.stop(this.ctx.currentTime + 0.3);
            }

            playPowerup() {
                if (this.muted || !this.ctx) return;
                const osc = this.ctx.createOscillator();
                const gain = this.ctx.createGain();
                osc.type = 'sine';
                osc.frequency.setValueAtTime(300, this.ctx.currentTime);
                osc.frequency.exponentialRampToValueAtTime(1200, this.ctx.currentTime + 0.25);
                gain.gain.setValueAtTime(0.2, this.ctx.currentTime);
                gain.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.25);
                osc.connect(gain);
                gain.connect(this.ctx.destination);
                osc.start();
                osc.stop(this.ctx.currentTime + 0.25);
            }
        }

        const soundFx = new SoundEngine();

        // --- Game Setup ---
        const canvas = document.getElementById('gameCanvas');
        const ctx = canvas.getContext('2d');

        const scoreText = document.getElementById('scoreText');
        const multiplierText = document.getElementById('multiplierText');
        const healthBar = document.getElementById('healthBar');
        const overlayScreen = document.getElementById('overlayScreen');
        const overlayTitle = document.getElementById('overlayTitle');
        const overlaySubtitle = document.getElementById('overlaySubtitle');
        const startBtn = document.getElementById('startBtn');
        const btnText = document.getElementById('btnText');
        const statsBox = document.getElementById('statsBox');
        const finalScore = document.getElementById('finalScore');
        const finalKills = document.getElementById('finalKills');
        const highScoreEl = document.getElementById('highScore');
        const soundToggleBtn = document.getElementById('soundToggleBtn');
        const soundIcon = document.getElementById('soundIcon');

        // Resize Canvas dynamically
        function resizeCanvas() {
            const rect = canvas.parentElement.getBoundingClientRect();
            canvas.width = rect.width;
            canvas.height = rect.height;
        }
        window.addEventListener('resize', resizeCanvas);
        resizeCanvas();

        // --- Input State ---
        const keys = {
            ArrowUp: false, ArrowDown: false, ArrowLeft: false, ArrowRight: false,
            w: false, s: false, a: false, d: false, Space: false
        };

        window.addEventListener('keydown', (e) => {
            if (e.code === 'Space') keys.Space = true;
            if (keys.hasOwnProperty(e.key) || keys.hasOwnProperty(e.code)) {
                keys[e.key] = true;
                keys[e.code] = true;
            }
        });

        window.addEventListener('keyup', (e) => {
            if (e.code === 'Space') keys.Space = false;
            if (keys.hasOwnProperty(e.key) || keys.hasOwnProperty(e.code)) {
                keys[e.key] = false;
                keys[e.code] = false;
            }
        });

        // Touch button handlers
        const bindTouch = (id, keyName) => {
            const el = document.getElementById(id);
            if (!el) return;
            el.addEventListener('touchstart', (e) => { e.preventDefault(); keys[keyName] = true; });
            el.addEventListener('touchend', (e) => { e.preventDefault(); keys[keyName] = false; });
        };
        bindTouch('btnUp', 'ArrowUp');
        bindTouch('btnDown', 'ArrowDown');
        bindTouch('btnLeft', 'ArrowLeft');
        bindTouch('btnRight', 'ArrowRight');
        bindTouch('btnShoot', 'Space');

        // --- Sound Toggle ---
        soundToggleBtn.addEventListener('click', () => {
            soundFx.muted = !soundFx.muted;
            if (soundFx.muted) {
                soundIcon.className = 'fas fa-volume-mute text-red-400 text-lg';
            } else {
                soundIcon.className = 'fas fa-volume-up text-lg';
            }
        });

        // --- Game Variables ---
        let gameActive = false;
        let score = 0;
        let kills = 0;
        let multiplier = 1;
        let highScore = localStorage.getItem('neon_high_score') || 0;
        let frameCount = 0;

        let player;
        let bullets = [];
        let enemies = [];
        let particles = [];
        let powerups = [];
        let stars = [];

        // Stars Background Initializer
        function initStars() {
            stars = [];
            for (let i = 0; i < 70; i++) {
                stars.push({
                    x: Math.random() * canvas.width,
                    y: Math.random() * canvas.height,
                    size: Math.random() * 2 + 0.5,
                    speed: Math.random() * 2 + 0.5,
                    color: Math.random() > 0.5 ? '#00f0ff' : '#ffffff'
                });
            }
        }

        // --- Entities ---
        class Player {
            constructor() {
                this.width = 40;
                this.height = 40;
                this.x = canvas.width / 2 - this.width / 2;
                this.y = canvas.height - 100;
                this.speed = 6;
                this.maxHealth = 100;
                this.health = 100;
                this.weaponLevel = 1; // 1: Single, 2: Double, 3: Triple
                this.lastShot = 0;
                this.shootDelay = 150; // ms
            }

            draw() {
                ctx.save();
                ctx.translate(this.x + this.width / 2, this.y + this.height / 2);

                // Ship Glow Effect
                ctx.shadowBlur = 15;
                ctx.shadowColor = '#00f0ff';

                // Ship Body (Futuristic Fighter Triangle)
                ctx.beginPath();
                ctx.moveTo(0, -this.height / 2);
                ctx.lineTo(this.width / 2, this.height / 2);
                ctx.lineTo(0, this.height / 4);
                ctx.lineTo(-this.width / 2, this.height / 2);
                ctx.closePath();
                ctx.fillStyle = '#00f0ff';
                ctx.fill();

                // Inner Cockpit
                ctx.beginPath();
                ctx.arc(0, 0, 6, 0, Math.PI * 2);
                ctx.fillStyle = '#ffffff';
                ctx.fill();

                // Engine Flame Effect
                ctx.beginPath();
                ctx.moveTo(-6, this.height / 3);
                ctx.lineTo(0, this.height / 2 + Math.random() * 12 + 4);
                ctx.lineTo(6, this.height / 3);
                ctx.fillStyle = '#ff007f';
                ctx.fill();

                ctx.restore();
            }

            update() {
                // Movement
                if ((keys.ArrowLeft || keys.a) && this.x > 0) this.x -= this.speed;
                if ((keys.ArrowRight || keys.d) && this.x < canvas.width - this.width) this.x += this.speed;
                if ((keys.ArrowUp || keys.w) && this.y > 0) this.y -= this.speed;
                if ((keys.ArrowDown || keys.s) && this.y < canvas.height - this.height) this.y += this.speed;

                // Automatic Shooting or Space Trigger
                const now = Date.now();
                if (keys.Space && now - this.lastShot > this.shootDelay) {
                    this.shoot();
                    this.lastShot = now;
                }
            }

            shoot() {
                soundFx.playShoot();
                if (this.weaponLevel === 1) {
                    bullets.push(new Bullet(this.x + this.width / 2, this.y, 0, -10));
                } else if (this.weaponLevel === 2) {
                    bullets.push(new Bullet(this.x + 8, this.y, 0, -10));
                    bullets.push(new Bullet(this.x + this.width - 8, this.y, 0, -10));
                } else {
                    bullets.push(new Bullet(this.x + this.width / 2, this.y, 0, -10));
                    bullets.push(new Bullet(this.x + 4, this.y, -2.5, -9));
                    bullets.push(new Bullet(this.x + this.width - 4, this.y, 2.5, -9));
                }
            }

            hit(damage) {
                this.health -= damage;
                createExplosion(this.x + this.width / 2, this.y + this.height / 2, '#ff0055', 10);
                if (this.health <= 0) {
                    this.health = 0;
                    endGame();
                }
                updateHUD();
            }
        }

        class Bullet {
            constructor(x, y, vx, vy) {
                this.x = x;
                this.y = y;
                this.vx = vx;
                this.vy = vy;
                this.radius = 3;
            }

            draw() {
                ctx.save();
                ctx.shadowBlur = 8;
                ctx.shadowColor = '#00f0ff';
                ctx.beginPath();
                ctx.arc(this.x, this.y, this.radius, 0, Math.PI * 2);
                ctx.fillStyle = '#ffffff';
                ctx.fill();
                ctx.restore();
            }

            update() {
                this.x += this.vx;
                this.y += this.vy;
            }
        }

        class Enemy {
            constructor() {
                this.width = 32;
                this.height = 32;
                this.x = Math.random() * (canvas.width - this.width);
                this.y = -this.height;
                this.speed = Math.random() * 2 + 2;
                this.type = Math.random() > 0.7 ? 'fast' : 'standard';
                
                if (this.type === 'fast') {
                    this.speed += 2;
                    this.color = '#ff007f';
                    this.hp = 1;
                } else {
                    this.color = '#ff9900';
                    this.hp = 2;
                }
            }

            draw() {
                ctx.save();
                ctx.shadowBlur = 10;
                ctx.shadowColor = this.color;

                ctx.translate(this.x + this.width / 2, this.y + this.height / 2);
                
                // Enemy Shape (Inverted Triangle/Diamond)
                ctx.beginPath();
                ctx.moveTo(0, this.height / 2);
                ctx.lineTo(this.width / 2, -this.height / 2);
                ctx.lineTo(-this.width / 2, -this.height / 2);
                ctx.closePath();
                ctx.fillStyle = this.color;
                ctx.fill();

                ctx.restore();
            }

            update() {
                this.y += this.speed;
            }
        }

        class Particle {
            constructor(x, y, color) {
                this.x = x;
                this.y = y;
                this.color = color;
                this.radius = Math.random() * 3 + 1;
                this.vx = (Math.random() - 0.5) * 6;
                this.vy = (Math.random() - 0.5) * 6;
                this.alpha = 1;
                this.decay = Math.random() * 0.03 + 0.015;
            }

            draw() {
                ctx.save();
                ctx.globalAlpha = this.alpha;
                ctx.beginPath();
                ctx.arc(this.x, this.y, this.radius, 0, Math.PI * 2);
                ctx.fillStyle = this.color;
                ctx.fill();
                ctx.restore();
            }

            update() {
                this.x += this.vx;
                this.y += this.vy;
                this.alpha -= this.decay;
            }
        }

        class Powerup {
            constructor(x, y) {
                this.x = x;
                this.y = y;
                this.radius = 12;
                this.speed = 2;
                this.type = Math.random() > 0.5 ? 'weapon' : 'heal';
            }

            draw() {
                ctx.save();
                ctx.shadowBlur = 12;
                ctx.shadowColor = this.type === 'weapon' ? '#00ffff' : '#00ff66';
                ctx.beginPath();
                ctx.arc(this.x, this.y, this.radius, 0, Math.PI * 2);
                ctx.fillStyle = this.type === 'weapon' ? '#00ffff' : '#00ff66';
                ctx.fill();

                ctx.fillStyle = '#000';
                ctx.font = '10px Tajawal';
                ctx.textAlign = 'center';
                ctx.textBaseline = 'middle';
                ctx.fillText(this.type === 'weapon' ? '⚡' : '❤️', this.x, this.y);
                ctx.restore();
            }

            update() {
                this.y += this.speed;
            }
        }

        // --- Helper Functions ---
        function createExplosion(x, y, color, count = 20) {
            for (let i = 0; i < count; i++) {
                particles.push(new Particle(x, y, color));
            }
        }

        function updateHUD() {
            scoreText.textContent = score;
            multiplierText.textContent = `x${multiplier}`;
            healthBar.style.width = `${player.health}%`;

            if (player.health < 30) {
                healthBar.className = "bg-red-600 h-full w-full transition-all duration-300 animate-pulse";
            } else {
                healthBar.className = "bg-gradient-to-r from-red-500 to-emerald-400 h-full w-full transition-all duration-300";
            }
        }

        function startGame() {
            soundFx.init();
            score = 0;
            kills = 0;
            multiplier = 1;
            bullets = [];
            enemies = [];
            particles = [];
            powerups = [];
            
            initStars();
            player = new Player();
            updateHUD();

            overlayScreen.classList.add('opacity-0', 'pointer-events-none');
            gameActive = true;
            requestAnimationFrame(gameLoop);
        }

        function endGame() {
            gameActive = false;
            soundFx.playExplosion();

            if (score > highScore) {
                highScore = score;
                localStorage.setItem('neon_high_score', highScore);
            }

            overlayTitle.textContent = "انتهت اللعبة!";
            overlayTitle.className = "text-3xl sm:text-5xl font-extrabold mb-2 glow-text-pink tracking-wider";
            overlaySubtitle.textContent = "لقد تم تدمير مركبتك الفضائية في المعركة.";
            
            finalScore.textContent = score;
            finalKills.textContent = kills;
            highScoreEl.textContent = highScore;
            statsBox.classList.remove('hidden');

            btnText.textContent = "إعادة اللعب";
            overlayScreen.classList.remove('opacity-0', 'pointer-events-none');
        }

        // --- Main Game Loop ---
        function gameLoop() {
            if (!gameActive) return;

            frameCount++;
            ctx.clearRect(0, 0, canvas.width, canvas.height);

            // 1. Stars Background Animation
            stars.forEach(star => {
                star.y += star.speed;
                if (star.y > canvas.height) {
                    star.y = 0;
                    star.x = Math.random() * canvas.width;
                }
                ctx.fillStyle = star.color;
                ctx.fillRect(star.x, star.y, star.size, star.size);
            });

            // 2. Player Processing
            player.update();
            player.draw();

            // 3. Bullets Processing
            for (let i = bullets.length - 1; i >= 0; i--) {
                const b = bullets[i];
                b.update();
                b.draw();

                if (b.y < -10 || b.x < 0 || b.x > canvas.width) {
                    bullets.splice(i, 1);
                }
            }

            // 4. Enemy Spawning Logic
            if (frameCount % Math.max(20, 60 - Math.floor(score / 500)) === 0) {
                enemies.push(new Enemy());
            }

            // 5. Enemies Processing & Collision
            for (let i = enemies.length - 1; i >= 0; i--) {
                const e = enemies[i];
                e.update();
                e.draw();

                // Check collision with player
                const distToPlayer = Math.hypot((e.x + e.width / 2) - (player.x + player.width / 2), (e.y + e.height / 2) - (player.y + player.height / 2));
                if (distToPlayer < (e.width / 2 + player.width / 3)) {
                    createExplosion(e.x + e.width / 2, e.y + e.height / 2, e.color, 15);
                    player.hit(20);
                    enemies.splice(i, 1);
                    continue;
                }

                // Check collision with bullets
                for (let j = bullets.length - 1; j >= 0; j--) {
                    const b = bullets[j];
                    const distToBullet = Math.hypot((e.x + e.width / 2) - b.x, (e.y + e.height / 2) - b.y);

                    if (distToBullet < e.width / 2 + b.radius) {
                        e.hp--;
                        bullets.splice(j, 1);
                        createExplosion(b.x, b.y, '#ffffff', 5);

                        if (e.hp <= 0) {
                            soundFx.playExplosion();
                            createExplosion(e.x + e.width / 2, e.y + e.height / 2, e.color, 25);

                            // Chance to drop powerup
                            if (Math.random() < 0.15) {
                                powerups.push(new Powerup(e.x + e.width / 2, e.y + e.height / 2));
                            }

                            score += (e.type === 'fast' ? 150 : 100) * multiplier;
                            kills++;

                            // Combo Multiplier Scaling
                            if (kills % 10 === 0 && multiplier < 5) {
                                multiplier++;
                            }

                            updateHUD();
                            enemies.splice(i, 1);
                            break;
                        }
                    }
                }

                // Remove enemies off-screen
                if (e.y > canvas.height + 50) {
                    enemies.splice(i, 1);
                }
            }

            // 6. Powerups Logic
            for (let i = powerups.length - 1; i >= 0; i--) {
                const p = powerups[i];
                p.update();
                p.draw();

                const dist = Math.hypot(p.x - (player.x + player.width / 2), p.y - (player.y + player.height / 2));
                if (dist < p.radius + player.width / 2) {
                    soundFx.playPowerup();
                    if (p.type === 'weapon') {
                        player.weaponLevel = Math.min(player.weaponLevel + 1, 3);
                    } else if (p.type === 'heal') {
                        player.health = Math.min(player.health + 30, player.maxHealth);
                        updateHUD();
                    }
                    createExplosion(p.x, p.y, p.type === 'weapon' ? '#00ffff' : '#00ff66', 15);
                    powerups.splice(i, 1);
                } else if (p.y > canvas.height + 20) {
                    powerups.splice(i, 1);
                }
            }

            // 7. Particles Update
            for (let i = particles.length - 1; i >= 0; i--) {
                const part = particles[i];
                part.update();
                part.draw();
                if (part.alpha <= 0) {
                    particles.splice(i, 1);
                }
            }

            requestAnimationFrame(gameLoop);
        }

        // Start Button Event Listener
        startBtn.addEventListener('click', startGame);

        // Initial setup on window load
        window.onload = () => {
            initStars();
            // Draw background initial frame
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            stars.forEach(star => {
                ctx.fillStyle = star.color;
                ctx.fillRect(star.x, star.y, star.size, star.size);
            });
        };
    </script>
</body><!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Neon Nebula Striker - لعبة حرب الفضاء</title>
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Font Awesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Google Font (Tajawal & Press Start 2P for Arcade style) -->
    <link href="https://fonts.googleapis.com/css2?family=Press+Start+2P&family=Tajawal:wght@400;700;900&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Tajawal', sans-serif;
            background-color: #090a0f;
            color: #fff;
            overflow: hidden;
            user-select: none;
            -webkit-user-select: none;
        }
        .arcade-font {
            font-family: 'Press Start 2P', monospace;
        }
        #gameCanvas {
            background: radial-gradient(circle at center, #111428 0%, #050608 100%);
            box-shadow: 0 0 30px rgba(0, 240, 255, 0.2);
        }
        .glow-text-cyan {
            text-shadow: 0 0 10px rgba(0, 243, 255, 0.8), 0 0 20px rgba(0, 243, 255, 0.4);
        }
        .glow-text-pink {
            text-shadow: 0 0 10px rgba(255, 0, 127, 0.8), 0 0 20px rgba(255, 0, 127, 0.4);
        }
        /* Custom UI Buttons */
        .arcade-btn {
            background: linear-gradient(135deg, #ff007f 0%, #7928ca 100%);
            transition: all 0.2s ease;
            box-shadow: 0 0 15px rgba(255, 0, 127, 0.4);
        }
        .arcade-btn:hover {
            transform: translateY(-2px) scale(1.02);
            box-shadow: 0 0 25px rgba(255, 0, 127, 0.7);
        }
        .arcade-btn:active {
            transform: translateY(1px);
        }
    </style>
</head>
<body class="flex flex-col items-center justify-center min-h-screen m-0 p-0 relative">

    <!-- Container for Canvas and UI -->
    <div class="relative w-full max-w-4xl h-[100vh] sm:h-[90vh] flex flex-col justify-center items-center p-2">

        <!-- Header / HUD Panel -->
        <div class="w-full max-w-2xl flex justify-between items-center bg-gray-900/80 backdrop-blur-md border border-cyan-500/30 rounded-t-xl px-6 py-3 text-sm sm:text-base z-10">
            <div class="flex items-center gap-4">
                <div class="flex items-center gap-2">
                    <i class="fas fa-trophy text-yellow-400"></i>
                    <span class="text-gray-400">النقاط:</span>
                    <span id="scoreText" class="arcade-font text-cyan-400 font-bold text-lg">0</span>
                </div>
                <div class="flex items-center gap-2">
                    <i class="fas fa-fire text-orange-500"></i>
                    <span class="text-gray-400">المضاعف:</span>
                    <span id="multiplierText" class="arcade-font text-yellow-400 font-bold">x1</span>
                </div>
            </div>
            
            <div class="flex items-center gap-6">
                <!-- Health Bar -->
                <div class="flex items-center gap-2">
                    <i class="fas fa-heart text-red-500"></i>
                    <div class="w-24 sm:w-32 bg-gray-700 h-3 rounded-full overflow-hidden border border-gray-600">
                        <div id="healthBar" class="bg-gradient-to-r from-red-500 to-emerald-400 h-full w-full transition-all duration-300"></div>
                    </div>
                </div>

                <!-- Mute Button -->
                <button id="soundToggleBtn" class="text-gray-400 hover:text-white transition focus:outline-none">
                    <i id="soundIcon" class="fas fa-volume-up text-lg"></i>
                </button>
            </div>
        </div>

        <!-- Main Canvas Area -->
        <div class="relative w-full max-w-2xl flex-1 flex items-center justify-center overflow-hidden border-x border-b border-cyan-500/30 rounded-b-xl">
            <canvas id="gameCanvas" class="w-full h-full block rounded-b-xl"></canvas>

            <!-- Start / Game Over Screen Overlay -->
            <div id="overlayScreen" class="absolute inset-0 bg-black/80 backdrop-blur-md flex flex-col justify-center items-center p-6 text-center z-20 transition-opacity duration-300">
                <h1 id="overlayTitle" class="text-3xl sm:text-5xl font-extrabold mb-2 glow-text-cyan tracking-wider">NEON STRIKER</h1>
                <p id="overlaySubtitle" class="text-gray-300 mb-8 max-w-md text-sm sm:text-base">دمر أسطول الأعداء الفضائي، اجمع التطويرات وحقق أعلى نتيجة ممكنة!</p>
                
                <!-- Stats Showcase on Game Over -->
                <div id="statsBox" class="hidden mb-6 bg-gray-800/60 p-4 rounded-lg border border-gray-700 w-64 text-right">
                    <div class="flex justify-between my-1">
                        <span class="text-gray-400">النتيجة النهائية:</span>
                        <span id="finalScore" class="arcade-font text-cyan-400">0</span>
                    </div>
                    <div class="flex justify-between my-1">
                        <span class="text-gray-400">الأعداء المدمَرين:</span>
                        <span id="finalKills" class="arcade-font text-pink-400">0</span>
                    </div>
                    <div class="flex justify-between my-1">
                        <span class="text-gray-400">أعلى نتيجة:</span>
                        <span id="highScore" class="arcade-font text-yellow-400">0</span>
                    </div>
                </div>

                <!-- Controls Guide -->
                <div class="mb-8 text-xs text-gray-400 bg-gray-900/50 p-3 rounded-lg border border-gray-800 max-w-xs">
                    <div class="font-bold text-gray-300 mb-1">التحكم:</div>
                    <p>⬅️ ➡️ أو A/D للتحريك الأفقي</p>
                    <p>⬆️ ⬇️ أو W/S للتحريك العمودي</p>
                    <p>المسافة (Space) لإطلاق النار تلقائياً / لمس الشاشة على الجوال</p>
                </div>

                <button id="startBtn" class="arcade-btn px-8 py-4 rounded-full font-bold text-lg text-white uppercase tracking-wider flex items-center gap-3 cursor-pointer">
                    <i class="fas fa-play"></i>
                    <span id="btnText">ابدأ اللعب الآن</span>
                </button>
            </div>
        </div>

        <!-- Mobile Touch Controls overlay (shown only on mobile) -->
        <div id="touchControls" class="w-full max-w-2xl flex justify-between items-center mt-3 px-4 sm:hidden">
            <div class="grid grid-cols-3 gap-2 w-36">
                <div></div>
                <button id="btnUp" class="bg-gray-800/80 active:bg-cyan-600 text-white p-4 rounded-lg flex items-center justify-center text-xl shadow"><i class="fas fa-arrow-up"></i></button>
                <div></div>
                <button id="btnLeft" class="bg-gray-800/80 active:bg-cyan-600 text-white p-4 rounded-lg flex items-center justify-center text-xl shadow"><i class="fas fa-arrow-left"></i></button>
                <button id="btnDown" class="bg-gray-800/80 active:bg-cyan-600 text-white p-4 rounded-lg flex items-center justify-center text-xl shadow"><i class="fas fa-arrow-down"></i></button>
                <button id="btnRight" class="bg-gray-800/80 active:bg-cyan-600 text-white p-4 rounded-lg flex items-center justify-center text-xl shadow"><i class="fas fa-arrow-right"></i></button>
            </div>
            <button id="btnShoot" class="bg-red-600/80 active:bg-red-500 text-white w-24 h-24 rounded-full flex items-center justify-center text-2xl font-bold shadow-lg border-2 border-red-400">
                <i class="fas fa-crosshairs"></i>
            </button>
        </div>

    </div>

    <!-- Game Logic Script -->
    <script>
        // --- Web Audio API Synth Engine ---
        class SoundEngine {
            constructor() {
                this.ctx = null;
                this.muted = false;
            }

            init() {
                if (!this.ctx) {
                    const AudioContext = window.AudioContext || window.webkitAudioContext;
                    this.ctx = new AudioContext();
                }
            }

            playShoot() {
                if (this.muted || !this.ctx) return;
                const osc = this.ctx.createOscillator();
                const gain = this.ctx.createGain();
                osc.type = 'sawtooth';
                osc.frequency.setValueAtTime(800, this.ctx.currentTime);
                osc.frequency.exponentialRampToValueAtTime(100, this.ctx.currentTime + 0.15);
                gain.gain.setValueAtTime(0.15, this.ctx.currentTime);
                gain.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.15);
                osc.connect(gain);
                gain.connect(this.ctx.destination);
                osc.start();
                osc.stop(this.ctx.currentTime + 0.15);
            }

            playExplosion() {
                if (this.muted || !this.ctx) return;
                // Noise buffer generation
                const bufferSize = this.ctx.sampleRate * 0.3;
                const buffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
                const data = buffer.getChannelData(0);
                for (let i = 0; i < bufferSize; i++) {
                    data[i] = Math.random() * 2 - 1;
                }
                const noise = this.ctx.createBufferSource();
                noise.buffer = buffer;

                const filter = this.ctx.createBiquadFilter();
                filter.type = 'lowpass';
                filter.frequency.setValueAtTime(1000, this.ctx.currentTime);
                filter.frequency.linearRampToValueAtTime(100, this.ctx.currentTime + 0.3);

                const gain = this.ctx.createGain();
                gain.gain.setValueAtTime(0.3, this.ctx.currentTime);
                gain.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.3);

                noise.connect(filter);
                filter.connect(gain);
                gain.connect(this.ctx.destination);

                noise.start();
                noise.stop(this.ctx.currentTime + 0.3);
            }

            playPowerup() {
                if (this.muted || !this.ctx) return;
                const osc = this.ctx.createOscillator();
                const gain = this.ctx.createGain();
                osc.type = 'sine';
                osc.frequency.setValueAtTime(300, this.ctx.currentTime);
                osc.frequency.exponentialRampToValueAtTime(1200, this.ctx.currentTime + 0.25);
                gain.gain.setValueAtTime(0.2, this.ctx.currentTime);
                gain.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.25);
                osc.connect(gain);
                gain.connect(this.ctx.destination);
                osc.start();
                osc.stop(this.ctx.currentTime + 0.25);
            }
        }

        const soundFx = new SoundEngine();

        // --- Game Setup ---
        const canvas = document.getElementById('gameCanvas');
        const ctx = canvas.getContext('2d');

        const scoreText = document.getElementById('scoreText');
        const multiplierText = document.getElementById('multiplierText');
        const healthBar = document.getElementById('healthBar');
        const overlayScreen = document.getElementById('overlayScreen');
        const overlayTitle = document.getElementById('overlayTitle');
        const overlaySubtitle = document.getElementById('overlaySubtitle');
        const startBtn = document.getElementById('startBtn');
        const btnText = document.getElementById('btnText');
        const statsBox = document.getElementById('statsBox');
        const finalScore = document.getElementById('finalScore');
        const finalKills = document.getElementById('finalKills');
        const highScoreEl = document.getElementById('highScore');
        const soundToggleBtn = document.getElementById('soundToggleBtn');
        const soundIcon = document.getElementById('soundIcon');

        // Resize Canvas dynamically
        function resizeCanvas() {
            const rect = canvas.parentElement.getBoundingClientRect();
            canvas.width = rect.width;
            canvas.height = rect.height;
        }
        window.addEventListener('resize', resizeCanvas);
        resizeCanvas();

        // --- Input State ---
        const keys = {
            ArrowUp: false, ArrowDown: false, ArrowLeft: false, ArrowRight: false,
            w: false, s: false, a: false, d: false, Space: false
        };

        window.addEventListener('keydown', (e) => {
            if (e.code === 'Space') keys.Space = true;
            if (keys.hasOwnProperty(e.key) || keys.hasOwnProperty(e.code)) {
                keys[e.key] = true;
                keys[e.code] = true;
            }
        });

        window.addEventListener('keyup', (e) => {
            if (e.code === 'Space') keys.Space = false;
            if (keys.hasOwnProperty(e.key) || keys.hasOwnProperty(e.code)) {
                keys[e.key] = false;
                keys[e.code] = false;
            }
        });

        // Touch button handlers
        const bindTouch = (id, keyName) => {
            const el = document.getElementById(id);
            if (!el) return;
            el.addEventListener('touchstart', (e) => { e.preventDefault(); keys[keyName] = true; });
            el.addEventListener('touchend', (e) => { e.preventDefault(); keys[keyName] = false; });
        };
        bindTouch('btnUp', 'ArrowUp');
        bindTouch('btnDown', 'ArrowDown');
        bindTouch('btnLeft', 'ArrowLeft');
        bindTouch('btnRight', 'ArrowRight');
        bindTouch('btnShoot', 'Space');

        // --- Sound Toggle ---
        soundToggleBtn.addEventListener('click', () => {
            soundFx.muted = !soundFx.muted;
            if (soundFx.muted) {
                soundIcon.className = 'fas fa-volume-mute text-red-400 text-lg';
            } else {
                soundIcon.className = 'fas fa-volume-up text-lg';
            }
        });

        // --- Game Variables ---
        let gameActive = false;
        let score = 0;
        let kills = 0;
        let multiplier = 1;
        let highScore = localStorage.getItem('neon_high_score') || 0;
        let frameCount = 0;

        let player;
        let bullets = [];
        let enemies = [];
        let particles = [];
        let powerups = [];
        let stars = [];

        // Stars Background Initializer
        function initStars() {
            stars = [];
            for (let i = 0; i < 70; i++) {
                stars.push({
                    x: Math.random() * canvas.width,
                    y: Math.random() * canvas.height,
                    size: Math.random() * 2 + 0.5,
                    speed: Math.random() * 2 + 0.5,
                    color: Math.random() > 0.5 ? '#00f0ff' : '#ffffff'
                });
            }
        }

        // --- Entities ---
        class Player {
            constructor() {
                this.width = 40;
                this.height = 40;
                this.x = canvas.width / 2 - this.width / 2;
                this.y = canvas.height - 100;
                this.speed = 6;
                this.maxHealth = 100;
                this.health = 100;
                this.weaponLevel = 1; // 1: Single, 2: Double, 3: Triple
                this.lastShot = 0;
                this.shootDelay = 150; // ms
            }

            draw() {
                ctx.save();
                ctx.translate(this.x + this.width / 2, this.y + this.height / 2);

                // Ship Glow Effect
                ctx.shadowBlur = 15;
                ctx.shadowColor = '#00f0ff';

                // Ship Body (Futuristic Fighter Triangle)
                ctx.beginPath();
                ctx.moveTo(0, -this.height / 2);
                ctx.lineTo(this.width / 2, this.height / 2);
                ctx.lineTo(0, this.height / 4);
                ctx.lineTo(-this.width / 2, this.height / 2);
                ctx.closePath();
                ctx.fillStyle = '#00f0ff';
                ctx.fill();

                // Inner Cockpit
                ctx.beginPath();
                ctx.arc(0, 0, 6, 0, Math.PI * 2);
                ctx.fillStyle = '#ffffff';
                ctx.fill();

                // Engine Flame Effect
                ctx.beginPath();
                ctx.moveTo(-6, this.height / 3);
                ctx.lineTo(0, this.height / 2 + Math.random() * 12 + 4);
                ctx.lineTo(6, this.height / 3);
                ctx.fillStyle = '#ff007f';
                ctx.fill();

                ctx.restore();
            }

            update() {
                // Movement
                if ((keys.ArrowLeft || keys.a) && this.x > 0) this.x -= this.speed;
                if ((keys.ArrowRight || keys.d) && this.x < canvas.width - this.width) this.x += this.speed;
                if ((keys.ArrowUp || keys.w) && this.y > 0) this.y -= this.speed;
                if ((keys.ArrowDown || keys.s) && this.y < canvas.height - this.height) this.y += this.speed;

                // Automatic Shooting or Space Trigger
                const now = Date.now();
                if (keys.Space && now - this.lastShot > this.shootDelay) {
                    this.shoot();
                    this.lastShot = now;
                }
            }

            shoot() {
                soundFx.playShoot();
                if (this.weaponLevel === 1) {
                    bullets.push(new Bullet(this.x + this.width / 2, this.y, 0, -10));
                } else if (this.weaponLevel === 2) {
                    bullets.push(new Bullet(this.x + 8, this.y, 0, -10));
                    bullets.push(new Bullet(this.x + this.width - 8, this.y, 0, -10));
                } else {
                    bullets.push(new Bullet(this.x + this.width / 2, this.y, 0, -10));
                    bullets.push(new Bullet(this.x + 4, this.y, -2.5, -9));
                    bullets.push(new Bullet(this.x + this.width - 4, this.y, 2.5, -9));
                }
            }

            hit(damage) {
                this.health -= damage;
                createExplosion(this.x + this.width / 2, this.y + this.height / 2, '#ff0055', 10);
                if (this.health <= 0) {
                    this.health = 0;
                    endGame();
                }
                updateHUD();
            }
        }

        class Bullet {
            constructor(x, y, vx, vy) {
                this.x = x;
                this.y = y;
                this.vx = vx;
                this.vy = vy;
                this.radius = 3;
            }

            draw() {
                ctx.save();
                ctx.shadowBlur = 8;
                ctx.shadowColor = '#00f0ff';
                ctx.beginPath();
                ctx.arc(this.x, this.y, this.radius, 0, Math.PI * 2);
                ctx.fillStyle = '#ffffff';
                ctx.fill();
                ctx.restore();
            }

            update() {
                this.x += this.vx;
                this.y += this.vy;
            }
        }

        class Enemy {
            constructor() {
                this.width = 32;
                this.height = 32;
                this.x = Math.random() * (canvas.width - this.width);
                this.y = -this.height;
                this.speed = Math.random() * 2 + 2;
                this.type = Math.random() > 0.7 ? 'fast' : 'standard';
                
                if (this.type === 'fast') {
                    this.speed += 2;
                    this.color = '#ff007f';
                    this.hp = 1;
                } else {
                    this.color = '#ff9900';
                    this.hp = 2;
                }
            }

            draw() {
                ctx.save();
                ctx.shadowBlur = 10;
                ctx.shadowColor = this.color;

                ctx.translate(this.x + this.width / 2, this.y + this.height / 2);
                
                // Enemy Shape (Inverted Triangle/Diamond)
                ctx.beginPath();
                ctx.moveTo(0, this.height / 2);
                ctx.lineTo(this.width / 2, -this.height / 2);
                ctx.lineTo(-this.width / 2, -this.height / 2);
                ctx.closePath();
                ctx.fillStyle = this.color;
                ctx.fill();

                ctx.restore();
            }

            update() {
                this.y += this.speed;
            }
        }

        class Particle {
            constructor(x, y, color) {
                this.x = x;
                this.y = y;
                this.color = color;
                this.radius = Math.random() * 3 + 1;
                this.vx = (Math.random() - 0.5) * 6;
                this.vy = (Math.random() - 0.5) * 6;
                this.alpha = 1;
                this.decay = Math.random() * 0.03 + 0.015;
            }

            draw() {
                ctx.save();
                ctx.globalAlpha = this.alpha;
                ctx.beginPath();
                ctx.arc(this.x, this.y, this.radius, 0, Math.PI * 2);
                ctx.fillStyle = this.color;
                ctx.fill();
                ctx.restore();
            }

            update() {
                this.x += this.vx;
                this.y += this.vy;
                this.alpha -= this.decay;
            }
        }

        class Powerup {
            constructor(x, y) {
                this.x = x;
                this.y = y;
                this.radius = 12;
                this.speed = 2;
                this.type = Math.random() > 0.5 ? 'weapon' : 'heal';
            }

            draw() {
                ctx.save();
                ctx.shadowBlur = 12;
                ctx.shadowColor = this.type === 'weapon' ? '#00ffff' : '#00ff66';
                ctx.beginPath();
                ctx.arc(this.x, this.y, this.radius, 0, Math.PI * 2);
                ctx.fillStyle = this.type === 'weapon' ? '#00ffff' : '#00ff66';
                ctx.fill();

                ctx.fillStyle = '#000';
                ctx.font = '10px Tajawal';
                ctx.textAlign = 'center';
                ctx.textBaseline = 'middle';
                ctx.fillText(this.type === 'weapon' ? '⚡' : '❤️', this.x, this.y);
                ctx.restore();
            }

            update() {
                this.y += this.speed;
            }
        }

        // --- Helper Functions ---
        function createExplosion(x, y, color, count = 20) {
            for (let i = 0; i < count; i++) {
                particles.push(new Particle(x, y, color));
            }
        }

        function updateHUD() {
            scoreText.textContent = score;
            multiplierText.textContent = `x${multiplier}`;
            healthBar.style.width = `${player.health}%`;

            if (player.health < 30) {
                healthBar.className = "bg-red-600 h-full w-full transition-all duration-300 animate-pulse";
            } else {
                healthBar.className = "bg-gradient-to-r from-red-500 to-emerald-400 h-full w-full transition-all duration-300";
            }
        }

        function startGame() {
            soundFx.init();
            score = 0;
            kills = 0;
            multiplier = 1;
            bullets = [];
            enemies = [];
            particles = [];
            powerups = [];
            
            initStars();
            player = new Player();
            updateHUD();

            overlayScreen.classList.add('opacity-0', 'pointer-events-none');
            gameActive = true;
            requestAnimationFrame(gameLoop);
        }

        function endGame() {
            gameActive = false;
            soundFx.playExplosion();

            if (score > highScore) {
                highScore = score;
                localStorage.setItem('neon_high_score', highScore);
            }

            overlayTitle.textContent = "انتهت اللعبة!";
            overlayTitle.className = "text-3xl sm:text-5xl font-extrabold mb-2 glow-text-pink tracking-wider";
            overlaySubtitle.textContent = "لقد تم تدمير مركبتك الفضائية في المعركة.";
            
            finalScore.textContent = score;
            finalKills.textContent = kills;
            highScoreEl.textContent = highScore;
            statsBox.classList.remove('hidden');

            btnText.textContent = "إعادة اللعب";
            overlayScreen.classList.remove('opacity-0', 'pointer-events-none');
        }

        // --- Main Game Loop ---
        function gameLoop() {
            if (!gameActive) return;

            frameCount++;
            ctx.clearRect(0, 0, canvas.width, canvas.height);

            // 1. Stars Background Animation
            stars.forEach(star => {
                star.y += star.speed;
                if (star.y > canvas.height) {
                    star.y = 0;
                    star.x = Math.random() * canvas.width;
                }
                ctx.fillStyle = star.color;
                ctx.fillRect(star.x, star.y, star.size, star.size);
            });

            // 2. Player Processing
            player.update();
            player.draw();

            // 3. Bullets Processing
            for (let i = bullets.length - 1; i >= 0; i--) {
                const b = bullets[i];
                b.update();
                b.draw();

                if (b.y < -10 || b.x < 0 || b.x > canvas.width) {
                    bullets.splice(i, 1);
                }
            }

            // 4. Enemy Spawning Logic
            if (frameCount % Math.max(20, 60 - Math.floor(score / 500)) === 0) {
                enemies.push(new Enemy());
            }

            // 5. Enemies Processing & Collision
            for (let i = enemies.length - 1; i >= 0; i--) {
                const e = enemies[i];
                e.update();
                e.draw();

                // Check collision with player
                const distToPlayer = Math.hypot((e.x + e.width / 2) - (player.x + player.width / 2), (e.y + e.height / 2) - (player.y + player.height / 2));
                if (distToPlayer < (e.width / 2 + player.width / 3)) {
                    createExplosion(e.x + e.width / 2, e.y + e.height / 2, e.color, 15);
                    player.hit(20);
                    enemies.splice(i, 1);
                    continue;
                }

                // Check collision with bullets
                for (let j = bullets.length - 1; j >= 0; j--) {
                    const b = bullets[j];
                    const distToBullet = Math.hypot((e.x + e.width / 2) - b.x, (e.y + e.height / 2) - b.y);

                    if (distToBullet < e.width / 2 + b.radius) {
                        e.hp--;
                        bullets.splice(j, 1);
                        createExplosion(b.x, b.y, '#ffffff', 5);

                        if (e.hp <= 0) {
                            soundFx.playExplosion();
                            createExplosion(e.x + e.width / 2, e.y + e.height / 2, e.color, 25);

                            // Chance to drop powerup
                            if (Math.random() < 0.15) {
                                powerups.push(new Powerup(e.x + e.width / 2, e.y + e.height / 2));
                            }

                            score += (e.type === 'fast' ? 150 : 100) * multiplier;
                            kills++;

                            // Combo Multiplier Scaling
                            if (kills % 10 === 0 && multiplier < 5) {
                                multiplier++;
                            }

                            updateHUD();
                            enemies.splice(i, 1);
                            break;
                        }
                    }
                }

                // Remove enemies off-screen
                if (e.y > canvas.height + 50) {
                    enemies.splice(i, 1);
                }
            }

            // 6. Powerups Logic
            for (let i = powerups.length - 1; i >= 0; i--) {
                const p = powerups[i];
                p.update();
                p.draw();

                const dist = Math.hypot(p.x - (player.x + player.width / 2), p.y - (player.y + player.height / 2));
                if (dist < p.radius + player.width / 2) {
                    soundFx.playPowerup();
                    if (p.type === 'weapon') {
                        player.weaponLevel = Math.min(player.weaponLevel + 1, 3);
                    } else if (p.type === 'heal') {
                        player.health = Math.min(player.health + 30, player.maxHealth);
                        updateHUD();
                    }
                    createExplosion(p.x, p.y, p.type === 'weapon' ? '#00ffff' : '#00ff66', 15);
                    powerups.splice(i, 1);
                } else if (p.y > canvas.height + 20) {
                    powerups.splice(i, 1);
                }
            }

            // 7. Particles Update
            for (let i = particles.length - 1; i >= 0; i--) {
                const part = particles[i];
                part.update();
                part.draw();
                if (part.alpha <= 0) {
                    particles.splice(i, 1);
                }
            }

            requestAnimationFrame(gameLoop);
        }

        // Start Button Event Listener
        startBtn.addEventListener('click', startGame);

        // Initial setup on window load
        window.onload = () => {
            initStars();
            // Draw background initial frame
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            stars.forEach(star => {
                ctx.fillStyle = star.color;
                ctx.fillRect(star.x, star.y, star.size, star.size);
            });
        };
    </script>
</body>
</html>
</html>
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TaskMasterApp());
}

class AppTheme {
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceAlt = Color(0xFF21262D);
  static const Color border = Color(0xFF30363D);
  static const Color primary = Color(0xFF1F6FEB);
  static const Color primaryLight = Color(0xFF58A6FF);
  static const Color success = Color(0xFF2EA043);
  static const Color danger = Color(0xFFCF222E);
  static const Color warning = Color(0xFFD29922);
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textMuted = Color(0xFF8B949E);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: primaryLight,
          surface: surface,
          error: danger,
          onPrimary: Colors.white,
          onSurface: textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceAlt,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primaryLight, width: 1.5),
          ),
        ),
      );
}

class Task {
  final String id;
  String title;
  bool done;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.done = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'done': done,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        done: json['done'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class TaskMasterApp extends StatelessWidget {
  const TaskMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مبارك',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const TaskHomePage(),
    );
  }
}

enum TaskFilter { all, active, completed }

class TaskHomePage extends StatefulWidget {
  const TaskHomePage({super.key});

  @override
  State<TaskHomePage> createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage>
    with SingleTickerProviderStateMixin {
  static const String _storageKey = 'klencod_tasks_v1';

  final List<Task> _tasks = [];
  final TextEditingController _searchController = TextEditingController();
  TaskFilter _filter = TaskFilter.all;
  String _searchQuery = '';
  bool _loading = true;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadTasks();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_storageKey);
      if (data != null && data.isNotEmpty) {
        final list = jsonDecode(data) as List<dynamic>;
        _tasks.clear();
        _tasks.addAll(list.map((e) => Task.fromJson(e as Map<String, dynamic>)));
      }
    } catch (_) {}
    setState(() => _loading = false);
    _fadeController.forward();
  }

  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_tasks.map((t) => t.toJson()).toList());
      await prefs.setString(_storageKey, data);
    } catch (_) {}
  }

  void _addTask(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _tasks.insert(
        0,
        Task(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: trimmed,
          createdAt: DateTime.now(),
        ),
      );
    });
    _saveTasks();
    HapticFeedback.lightImpact();
    _showSnack('تمت إضافة المهمة', success: true);
  }

  void _toggleTask(Task task) {
    setState(() => task.done = !task.done);
    _saveTasks();
    HapticFeedback.selectionClick();
  }

  void _deleteTask(Task task) {
    final index = _tasks.indexOf(task);
    if (index == -1) return;
    setState(() => _tasks.removeAt(index));
    _saveTasks();
    _showSnack(
      'تم حذف المهمة',
      actionLabel: 'تراجع',
      onAction: () {
        setState(() => _tasks.insert(index, task));
        _saveTasks();
      },
    );
  }

  void _clearCompleted() {
    final completed = _tasks.where((t) => t.done).toList();
    if (completed.isEmpty) {
      _showSnack('لا توجد مهام مكتملة');
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => _buildConfirmDialog(
        ctx,
        title: 'حذف المهام المكتملة',
        message: 'سيتم حذف ${completed.length} مهمة مكتملة. لا يمكن التراجع.',
        onConfirm: () {
          setState(() => _tasks.removeWhere((t) => t.done));
          _saveTasks();
          Navigator.pop(ctx);
          _showSnack('تم حذف ${completed.length} مهمة', success: true);
        },
      ),
    );
  }

  void _showSnack(String message,
      {String? actionLabel, VoidCallback? onAction, bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.info_outline_rounded,
              color: success ? AppTheme.success : AppTheme.textPrimary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.surfaceAlt,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: AppTheme.primaryLight,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }

  Widget _buildConfirmDialog(
    BuildContext ctx, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    return AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(title, style: const TextStyle(color: AppTheme.textPrimary)),
      content: Text(message, style: const TextStyle(color: AppTheme.textMuted)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('إلغاء',
              style: TextStyle(color: AppTheme.textMuted)),
        ),
        TextButton(
          onPressed: onConfirm,
          child: const Text('تأكيد',
              style: TextStyle(
                  color: AppTheme.danger, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  void _openAddDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: const [
            Icon(Icons.add_task_rounded, color: AppTheme.primaryLight),
            SizedBox(width: 10),
            Text('مهمة جديدة',
                style: TextStyle(color: AppTheme.textPrimary)),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (v) {
            _addTask(v);
            Navigator.pop(ctx);
          },
          decoration: const InputDecoration(
            hintText: 'اكتب المهمة...',
            prefixIcon: Icon(Icons.edit_rounded),
          ),
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء',
                style: TextStyle(color: AppTheme.textMuted)),
          ),
          FilledButton(
            onPressed: () {
              _addTask(controller.text);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  List<Task> get _visibleTasks {
    Iterable<Task> result = _tasks;
    if (_filter == TaskFilter.active) {
      result = result.where((t) => !t.done);
    } else if (_filter == TaskFilter.completed) {
      result = result.where((t) => t.done);
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((t) => t.title.toLowerCase().contains(q));
    }
    return result.toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryLight),
        ),
      );
    }

    final visible = _visibleTasks;
    final total = _tasks.length;
    final completed = _tasks.where((t) => t.done).length;
    final active = total - completed;
    final progress = total == 0 ? 0.0 : completed / total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('مبارك'),
        actions: [
          if (completed > 0)
            IconButton(
              tooltip: 'حذف المكتملة',
              icon: const Icon(Icons.delete_sweep_rounded),
              onPressed: _clearCompleted,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('مهمة جديدة',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildHeader(total, completed, active, progress),
          _buildSearchBar(),
          _buildFilters(total, active, completed),
          Expanded(
            child: visible.isEmpty
                ? _buildEmptyState()
                : _buildTaskList(visible),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int total, int completed, int active, double progress) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1F6FEB), Color(0xFF0D419D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.task_alt_rounded,
                    color: Colors.white, size: 28),
                const SizedBox(width: 10),
                Text(
                  total == 0 ? 'لا توجد مهام بعد' : 'مهامك',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statChip('الإجمالي', total, Colors.white),
                _statChip('نشطة', active, AppTheme.warning),
                _statChip('مكتملة', completed, AppTheme.success),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 600),
                builder: (_, value, __) => LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: Colors.white24,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(progress * 100).toStringAsFixed(0)}% إنجاز',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: 'بحث في المهام...',
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppTheme.textMuted),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      color: AppTheme.textMuted),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildFilters(int total, int active, int completed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _filterChip('الكل', TaskFilter.all, total),
          const SizedBox(width: 8),
          _filterChip('نشطة', TaskFilter.active, active),
          const SizedBox(width: 8),
          _filterChip('مكتملة', TaskFilter.completed, completed),
        ],
      ),
    );
  }

  Widget _filterChip(String label, TaskFilter filter, int count) {
    final selected = _filter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filter = filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary : AppTheme.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppTheme.primaryLight : AppTheme.border,
            ),
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  color: selected ? Colors.white : AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white70 : AppTheme.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Task> visible) {
    return FadeTransition(
      opacity: _fadeController,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
        itemCount: visible.length,
        itemBuilder: (context, index) {
          final task = visible[index];
          return _buildTaskItem(task);
        },
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.danger,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_rounded,
            color: Colors.white, size: 26),
      ),
      confirmDismiss: (_) async {
        _deleteTask(task);
        return false;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: task.done
                ? AppTheme.success.withOpacity(0.4)
                : AppTheme.border,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _toggleTask(task),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: task.done
                          ? AppTheme.success
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: task.done
                            ? AppTheme.success
                            : AppTheme.textMuted,
                        width: 2,
                      ),
                    ),
                    child: task.done
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 18)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            color: task.done
                                ? AppTheme.textMuted
                                : AppTheme.textPrimary,
                            fontSize: 15,
                            decoration: task.done
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(task.createdAt),
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'حذف',
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppTheme.textMuted),
                    onPressed: () => _deleteTask(task),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays == 1) return 'أمس';
    return 'منذ ${diff.inDays} يوم';
  }

  Widget _buildEmptyState() {
    final String message;
    final IconData icon;
    if (_searchQuery.isNotEmpty) {
      message = 'لا توجد نتائج للبحث';
      icon = Icons.search_off_rounded;
    } else if (_filter == TaskFilter.completed) {
      message = 'لا توجد مهام مكتملة بعد';
      icon = Icons.check_circle_outline_rounded;
    } else if (_filter == TaskFilter.active) {
      message = 'كل المهام مكتملة!';
      icon = Icons.celebration_rounded;
    } else {
      message = 'ابدأ بإضافة مهمتك الأولى';
      icon = Icons.playlist_add_rounded;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceAlt,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.border),
            ),
            child: Icon(icon, size: 56, color: AppTheme.primaryLight),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'استخدم الزر أدناه للبدء',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}