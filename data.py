import pandas as pd

save=True

#limitiColonne=660


#nome con sui sarà salvato il file
NAME_FILE='ecpi_m.txt'

PATH_DATA="/home/ggioalema/Uni/FinantialDataS/Data/"

# Carica un file Excel in un DataFrame 
file_name=PATH_DATA+'Inflation-data.xlsx'

print(f"Contents of file '{file_name}':\n")

# Reading multiple sheets from an Excel file
sheets_dict = pd.read_excel(file_name, engine="openpyxl", sheet_name=None)
i=0
# Accessing individual sheets and displaying their contents
for sheet_name, df in sheets_dict.items():
    
#    print(f"Sheet '{sheet_name}':\n{df}\n")
    print(f"indice:{i}\t{sheet_name}")
    i+=1

#print(sheet_name)

index=int(input("Quale scegliamo?: "))

i=0
for sheet_name, df in sheets_dict.items():

    if i==index:
        data=df

    i+=1

#print(data)

print(type(data))

# Ensure all column names are strings, then filter out 'Unnamed' columns
data = data.loc[:, ~data.columns.astype(str).str.contains('^Unnamed')]

#data=data.iloc[:,:limitiColonne]

#print(data.iloc[0,:])

data=data.drop(["Country Code", "IMF Country Code" , "Indicator Type", "Series Name", "Data source", "Note", ], axis="columns")

print(data.iloc[:,0])

data = data.map(lambda x: str(x).replace(',', '.') if isinstance(x, str) else x)

if save:

    data.to_csv(NAME_FILE, sep='\t', index=False, na_rep="NaN")

    print("File salvato correttamente con valori numerici formattati.")