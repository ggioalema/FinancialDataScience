% Percorso del file da caricare
filePath = 'hcpi_m.txt';

% Legge il file .txt come una tabella
data = readtable(filePath, 'Delimiter', '\t', 'TreatAsEmpty', 'NaN', 'ReadVariableNames', true);

% Mostra i primi 5 record per confermare la lettura
%disp(head(data, 5));

% Selezionare la terza riga (puoi cambiare il numero a tuo piacimento)
rowNumber = 54;
selectedRow = data(rowNumber, :);

% Mostra la riga selezionata con i nomi delle colonne
disp(selectedRow);

