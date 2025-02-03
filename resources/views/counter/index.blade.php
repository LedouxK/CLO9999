<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Counter Page</title>
</head>
<body>
    <h1>Counter Page</h1>

    <div>
        <span id="count-value">Loading...</span>
        <button id="increment-btn">Click me</button>
    </div>

    <script>
        async function fetchCount() {
            try {
                const response = await fetch('/api/click');
                if (!response.ok) {
                    console.error('Erreur lors du GET /api/click', response.status);
                    return;
                }
                const data = await response.json();
                document.getElementById('count-value').textContent = data.count;
            } catch (error) {
                console.error(error);
            }
        }

        async function incrementCount() {
            try {
                const response = await fetch('/api/click', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    }
                });
                if (!response.ok) {
                    console.error('Erreur lors du POST /api/click', response.status);
                    return;
                }
                const data = await response.json();
                document.getElementById('count-value').textContent = data.count;
            } catch (error) {
                console.error(error);
            }
        }

        document.addEventListener('DOMContentLoaded', () => {
            // Récupère la valeur actuelle du compteur au chargement
            fetchCount();

            // Gère le clic sur le bouton
            document.getElementById('increment-btn')
                    .addEventListener('click', incrementCount);
        });
    </script>
</body>
</html>
