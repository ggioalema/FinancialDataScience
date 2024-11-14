clc;clearvars;close all

% 1. Carica il dataset come tabella, assicurandoti di leggere la prima riga come nomi delle colonne
filePath = 'hcpi_m.txt';
data = readtable(filePath, 'Delimiter', '\t', 'TreatAsEmpty', 'NaN', 'ReadVariableNames', true);

% 2. Estrai i nomi dei Paesi (prima colonna) e le serie temporali (tutte le altre colonne)
countryNames = data{:, 1};  % Prima colonna con i nomi dei Paesi
timeSeriesData = data{:, 200:300};  % Dati numerici delle serie temporali

disp(timeSeriesData)

% 3. Calcola la matrice di correlazione tra le serie temporali
correlationMatrix = corr(timeSeriesData', 'Rows', 'pairwise');  % 'pairwise' ignora i NaN in ogni confronto

correlationMatrix=correlationMatrix-diag(diag(correlationMatrix));

% 5. Imposta una soglia per definire la connettività (ad esempio, 0.8)
threshold = 0.9;
adjacencyMatrix = correlationMatrix > threshold;  % Crea una matrice di adiacenza basata sulla soglia

% 6. Crea il grafo usando la matrice di adiacenza
G = graph(adjacencyMatrix, countryNames);

% 7. Visualizza il grafo
figure;
plot(G);
title('Network of Countries Based on Time Series Correlation');
