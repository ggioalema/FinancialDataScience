import pandas as pd
import numpy as np
import networkx as nx
import matplotlib.pyplot as plt

# 1. Carica il dataset
file_path = 'hcpi_m.txt'  # Il file .txt separato da tabulazioni
data = pd.read_csv(file_path, sep='\t')

# Seleziona un sottoinsieme di dati
data = data.iloc[:, :]

# 2. Estrai i nomi dei Paesi e le serie temporali
country_names = data.iloc[:-1, 0].values  # La prima colonna contiene i Paesi
time_series_data = data.iloc[:-1, 1:]  # Le altre colonne contengono le serie temporali e trasponiamo per avere Paesi come colonne

#print(np.shape(country_names))
#print(country_names)
#print(np.shape(time_series_data))

#exit(1)

# 3. Gestisci i NaN (sostituire NaN con 0 o altre strategie)
time_series_df = pd.DataFrame(time_series_data, columns=country_names)  # Usa i nomi dei Paesi come colonne
time_series_df = time_series_df.fillna(0)  # Gestisce i NaN sostituendoli con 0 (o puoi usare un'altra strategia)

# 4. Calcola la matrice di correlazione tra Paesi ignorando NaN
correlation_matrix = time_series_df.corr(method='pearson')  # Pearson è il metodo di default in Pandas

# 5. Imposta una soglia di correlazione per definire la connettività
threshold = 0.0
adjacency_matrix = (correlation_matrix > threshold).astype(int)  # 1 se sopra la soglia, altrimenti 0

# 6. Crea il grafo usando networkx
G = nx.from_numpy_array(adjacency_matrix.values)  # Crea il grafo dalla matrice di adiacenza (con from_numpy_array)
G = nx.relabel_nodes(G, dict(enumerate(country_names)))  # Rinomina i nodi con i nomi dei Paesi

# 7. Visualizza il grafo
plt.figure(figsize=(10, 10))
nx.draw(G, with_labels=True, node_size=2000, node_color='lightblue', font_size=7, font_weight='bold', edge_color='red')
plt.title('Network of Countries Based on Time Series Correlation')
plt.show()


