import matplotlib.pyplot as plt
import matplotlib.patches as patches

# Crea una nuova figura e assi
fig, ax = plt.subplots()

# Disegna la parte centrale con un rettangolo
rect = patches.Rectangle((0.4, 0.2), 0.2, 0.5, linewidth=2, edgecolor='black', facecolor='tan')
ax.add_patch(rect)

# Disegna i due cerchi come "basi"
circle1 = patches.Circle((0.45, 0.15), 0.1, linewidth=2, edgecolor='black', facecolor='tan')
circle2 = patches.Circle((0.55, 0.15), 0.1, linewidth=2, edgecolor='black', facecolor='tan')
ax.add_patch(circle1)
ax.add_patch(circle2)

# Imposta i limiti dell'asse e rimuovi i tick
ax.set_xlim(0, 1)
ax.set_ylim(0, 1)
ax.axis('off')  # Rimuovi gli assi per un aspetto più pulito

plt.show()
