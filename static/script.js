// Form submission handler
function searchPlayer(event) {
    event.preventDefault();

    const input = document.getElementById('playerTag');
    let tag = input.value.trim();

    // Remove # if present for URL
    tag = tag.replace('#', '');

    if (tag) {
        // Show loading state
        const button = event.target.querySelector('button');
        const originalText = button.innerHTML;
        button.innerHTML = '<span class="loading"></span> Searching...';
        button.disabled = true;

        // Navigate to player stats page
        window.location.href = `/player/${tag}`;
    }
}

// Input formatting
document.addEventListener('DOMContentLoaded', () => {
    const input = document.getElementById('playerTag');

    if (input) {
        input.addEventListener('input', (e) => {
            // Auto-uppercase
            e.target.value = e.target.value.toUpperCase();
        });

        // Focus on page load
        input.focus();
    }

    // Animate elements on scroll
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);

    // Observe stat cards
    document.querySelectorAll('.stat-card, .roast-card').forEach(card => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        card.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
        observer.observe(card);
    });
});

// Counter animation for stats
function animateCounter(element, target, duration = 1000) {
    const start = 0;
    const increment = target / (duration / 16);
    let current = start;

    const timer = setInterval(() => {
        current += increment;
        if (current >= target) {
            element.textContent = target;
            clearInterval(timer);
        } else {
            element.textContent = Math.floor(current);
        }
    }, 16);
}

// Smooth scroll
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});
