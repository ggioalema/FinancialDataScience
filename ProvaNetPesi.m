clc;clearvars;close all

% 1. Carica il dataset come tabella, assicurandoti di leggere la prima riga come nomi delle colonne
filePath = 'hcpi_m.txt';
data = readtable(filePath, 'Delimiter', '\t', 'TreatAsEmpty', 'NaN', 'ReadVariableNames', true);

NomiDate = data.Properties.VariableNames;
NomiDate = NomiDate(2:end);

%disp(size(NomiDate));

%decido se plottare strenght o distr di grado
str=input("Vuoi plottare le strenght? (Y/N)", 's'); 

if lower(str)=='y'
    str=true;

else 
    str=false;
end
%PULISCO DATI DA TROPPI NaN

% Soglia per la percentuale di NaN
soglia = 0.1;  

%threshold per considerare link
threshold=2;

%elementi per grafo PER QUALCHE MOTIVO NON FUNZIONA CON TUTTI VALORI POSSIBILI :(
Nelementi=24;           %N elemnti temporali per grafo
stepTemporali=18;       %step saltati da un grafo all'altro


% Estrai solo le colonne numeriche dalla tabella
numericData = data{:, varfun(@isnumeric, data, 'Output', 'uniform')};  % Solo colonne numeriche
numNaNPerRiga = sum(isnan(numericData), 2);  % Somma lungo ogni riga

% Calcola la percentuale di NaN in ogni riga
percentNaNPerRiga = numNaNPerRiga / size(numericData, 2);  % Dividi per il numero totale di colonne
righeDaEscludere = percentNaNPerRiga > soglia;
dataPulita = data(~righeDaEscludere, :);

% SCEGLIERE SOTTOINSIEME DEI DATI

countryNames = dataPulita{:, 1};  
timeSeriesData = dataPulita{:, 2:end};  % Dati numerici delle serie temporali, evitando la prima colonna

%disp(class(timeSeriesData))
disp(size(timeSeriesData))
%disp(NomiDate(end))

numColonne=size(timeSeriesData, 2);
numGrafi=ceil((numColonne-Nelementi)/stepTemporali)+1;
%disp(numGrafi);

graphs = cell(1, numGrafi);  % Prealloca un array di celle
titoli={};


for i=1:numGrafi
    
    inizio=(i-1)*stepTemporali+1;
    fine=(i-1)*stepTemporali+Nelementi+1;
    
    if fine>numColonne
        fine=numColonne;
    end
    fprintf('grafo numero %d, inizio: %d\tfine: %d\n', i, inizio, fine)

    datiTemp=timeSeriesData(:, inizio:fine);

    %disp(size(datiTemp))
    
    graphs{i}=creaNetwork(countryNames, datiTemp, threshold);
    titoli{end+1}=  sprintf('da %s a %s', NomiDate{inizio}, NomiDate{fine}); %#ok<SAGROW>
end


nCols = ceil(sqrt(numGrafi));  % Numero di colonne per il layout della griglia
nRows = ceil(numGrafi / nCols);  % Numero di righe per il layout della griglia


% Ciclo su ogni grafo nel cell array e lo plottiamo in un sottopannello
for i = 1:numGrafi
    % Seleziona la posizione del sottopannello usando subplot
    subplot(nRows, nCols, i);
    
    % Estrai il grafo corrente
    G = graphs{i};


    % Plotta il grafo con le opzioni preferite
    p = plot(G, 'LineWidth', max(5*G.Edges.Weight, 1));
    
    % Aggiungi un titolo per identificare il grafo, se necessario
    title(titoli(i));
    
    % Opzioni di visualizzazione (dimensione nodo, larghezza linee ecc.)
    p.NodeColor = 'blue';  % Colore dei nodi
    %p.LineWidth = 1.5;     % Larghezza degli archi
    p.MarkerSize = 4;      % Dimensione dei nodi

    D=degree(G);
    histogram(D, 20);

    if str
        strength= trovaStrenght(G);
        histogram(strength, 20);
    end
    title(titoli(i));
end

% Imposta il titolo della figura
sgtitle('Multiple Network Plots');

function strength= trovaStrenght(G)
    % Ottieni gli archi e i pesi
    edges = G.Edges.EndNodes;  % Matrice con le connessioni tra i nodi
    weights = G.Edges.Weight;   % Pesi degli archi

    % Ottieni i nomi dei nodi
    nodeNames = G.Nodes.Name;  

    % Inizializza l'array per la strength dei nodi
    strength = zeros(1, numnodes(G));

    % Calcola la strength per ogni nodo
    for i = 1:numnodes(G)
        % Trova la stringa che rappresenta il nodo corrente
        nodeName = nodeNames{i};
        
        % Usa indicizzazione logica per trovare gli archi in uscita dal nodo
        edgesFromNode = strcmp(edges(:,1), nodeName);  % confronta le stringhe
        % Somma i pesi degli archi in uscita dal nodo corrente
        strength(i) = sum(weights(edgesFromNode));
        
        % Usa indicizzazione logica per trovare gli archi in entrata nel nodo
        edgesToNode = strcmp(edges(:,2), nodeName);  % confronta le stringhe
        % Somma i pesi degli archi in entrata nel nodo corrente
        strength(i) = strength(i) + sum(weights(edgesToNode));
    end

end

function G=creaNetwork(countryNames, timeSeriesData, threshold)
    
    correlationMatrix = corr(timeSeriesData', 'Type' , 'Pearson' ,'Rows', 'pairwise');  % 'pairwise' ignora i NaN in ogni confronto

    %size(correlationMatrix)

    distanceMatrix = sqrt(2*(1-correlationMatrix));

    distanceMatrix = 1 ./ distanceMatrix;

    %disp("size distanceMatrix")
    %disp(size(distanceMatrix));
    %disp(max(max(distanceMatrix)));

    % Replace NaN or Inf values in distanceMatrix with a large distance (or some other meaningful value)
    distanceMatrix(isnan(distanceMatrix) | isinf(distanceMatrix)) = max(distanceMatrix(~isnan(distanceMatrix) & ~isinf(distanceMatrix)), [], 'all');

    % Mantiene i pesi solo per correlazioni sopra la soglia
    
    weightedAdjacencyMatrix = distanceMatrix .* (distanceMatrix > threshold);  
    %weightedAdjacencyMatrix = (weightedAdjacencyMatrix-threshold)/(max(max(weightedAdjacencyMatrix))-threshold); 
    %normalizzo pesi sopra la soglia(se no sono molto simili tra loro)
    %tolgo la diagonale
    %weightedAdjacencyMatrix = weightedAdjacencyMatrix-diag(diag(weightedAdjacencyMatrix));

    % Zero out the diagonal (or explicitly set to zero for safety)
    weightedAdjacencyMatrix(1:size(weightedAdjacencyMatrix, 1) + 1:end) = 0;

    %disp(weightedAdjacencyMatrix(1:10, 1:10));
    
    %disp(max(max(weightedAdjacencyMatrix)))

    %isSymmetric = issymmetric(weightedAdjacencyMatrix);
    %disp(isSymmetric);
    G = graph(weightedAdjacencyMatrix, countryNames);

end


