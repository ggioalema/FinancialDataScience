clc;clearvars;close all

% 1. Carica il dataset come tabella, assicurandoti di leggere la prima riga come nomi delle colonne
filePath = 'hcpi_m.txt';
data = readtable(filePath, 'Delimiter', '\t', 'TreatAsEmpty', 'NaN', 'ReadVariableNames', true);


k=5; %num nearest neighboor in calcolo mi

%threshold per considerare una connessione
threshold = 0.97;

% Soglia per la percentuale di NaN
soglia = 0.1;  


%PULISCO DATI DA TROPPI NaN

% Estrai solo le colonne numeriche dalla tabella
numericData = data{:, varfun(@isnumeric, data, 'Output', 'uniform')};  % Solo colonne numeriche
numNaNPerRiga = sum(isnan(numericData), 2);  % Somma lungo ogni riga

% Calcola la percentuale di NaN in ogni riga
percentNaNPerRiga = numNaNPerRiga / size(numericData, 2);  % Dividi per il numero totale di colonne
righeDaEscludere = percentNaNPerRiga > soglia;
dataPulita = data(~righeDaEscludere, :);

% 2. Estrai i nomi dei Paesi (prima colonna) e le serie temporali (tutte le altre colonne)

% SCEGLIERE SOTTOINSIEME DEI DATI

countryNames = dataPulita{:, 1};  
timeSeriesData = dataPulita{:, 550:600};  % Dati numerici delle serie temporali, evitando la prima colonna

fprintf('numero di stati/nodi: %d\n', size(countryNames))


% 3. Calcola la matrice di mutua informazione tra le serie temporali
% Prealloca la matrice di MI
numCountries = size(timeSeriesData, 1);
MI_matrix = zeros(numCountries);

% Calcola la mutua informazione tra tutte le coppie di righe
for i = 1:numCountries
    for j = i+1:numCountries
        MI_matrix(i, j) = mutual_information(timeSeriesData(i, :), timeSeriesData(j, :));
        %MI_matrix(i, j) = mi_cont_cont(timeSeriesData(i, :), timeSeriesData(j, :), k);
        MI_matrix(j, i) = MI_matrix(i, j);  % La matrice è simmetrica
    end
end

% 4. Crea la matrice di adiacenza pesata, mantenendo solo i valori sopra la soglia
% Mantiene i pesi solo per correlazioni sopra la soglia
weightedAdjacencyMatrix = MI_matrix .* (MI_matrix > threshold);  
%normalizzo pesi sopra la soglia(se no sono molto simili tra loro)
weightedAdjacencyMatrix = weightedAdjacencyMatrix/max(max(weightedAdjacencyMatrix)); 
%tolgo la diagonale
weightedAdjacencyMatrix = weightedAdjacencyMatrix-diag(diag(weightedAdjacencyMatrix));


% 5. Crea il grafo e le linee che rappresentano i link
G = graph(weightedAdjacencyMatrix, countryNames);

% 6. Visualizza il grafo
figure;
%plot(G, 'EdgeLabel', G.Edges.Weight);  % Visualizza i pesi sugli archi
%plot(G)
p = plot(G, 'LineWidth', max(5*G.Edges.Weight, 1));

D=degree(G);

histogram(D, 20);

%plot(D);

title('Weighted Network of Countries Based on Time Series Correlation');



function MI = mutual_information(x, y)
    % Calcola la mutua informazione tra i vettori x e y.
    % Assicurati che x e y siano vettori di numeri.
    
    % Stima la densità di probabilità con l'istogramma bidimensionale
    numBins = 50;  % Numero di bin per la stima della probabilità
    jointHist = histcounts2(x, y, numBins, 'Normalization', 'probability');
    
    % Marginali
    px = sum(jointHist, 2);  % Somma lungo le colonne per ottenere la marginale di x
    py = sum(jointHist, 1);  % Somma lungo le righe per ottenere la marginale di y
    
    % Calcolo della mutua informazione
    MI = 0;
    for i = 1:numBins
        for j = 1:numBins
            if jointHist(i, j) > 0
                MI = MI + jointHist(i, j) * log(jointHist(i, j) / (px(i) * py(j)));
            end
        end
    end
end


