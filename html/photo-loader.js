async function loadPhotoGrid(folder) {
    try {
        const response = await fetch(`${folder}/`);
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        const html = await response.text();

        const parser = new DOMParser();
        const doc = parser.parseFromString(html, 'text/html');
        const imagePattern = /\.(jpg|jpeg|png|gif|webp)$/i;
        const photos = Array.from(doc.querySelectorAll('a[href]'))
            .map(a => a.getAttribute('href'))
            .filter(href => imagePattern.test(href));

        const grid = document.querySelector('.photo-grid');
        photos.forEach(file => {
            const a = document.createElement('a');
            const img = document.createElement('img');

            a.href = `${folder}/${file}`;
            img.src = `${folder}/thumbs/${file}`;
            img.alt = file.replace(/\.[^.]+$/, '');
            img.loading = 'lazy';

            img.onload = function() {
                if (this.naturalWidth > this.naturalHeight) {
                    a.classList.add('landscape');
                }
            };

            a.appendChild(img);
            grid.appendChild(a);
        });
    } catch (err) {
        console.error('Failed to load photos:', err);
    }
}
