import pandas as pd
import psycopg2
import time

#Es necesario correr primero el ejer3.4.sql para crear la tabla y demas

def main():
    global connected
    connection = connect()
    if(connected):
        runQueries(connection)
        connection.close() #cerrar conexion
    else:
        print("No se pudo conectar. Chequee los valores en la funcion connect")

    

def runQueries(connection):
    cursor = connection.cursor()
    dataFrame = getDataframe('top-1m.csv')
   

    start_time = time.time()            #iniciar temporizador
    
    insertValues(cursor, dataFrame)     #insertar valores
    cursor.execute("UPDATE sitio SET pais = country.name FROM country WHERE sitio.countrycode = country.code;") #Matchear CountryCode con Nombre del Pais
    connection.commit()                 #hacer commit para guardar los cambios
    
    end_time = time.time()              #parar temporizador
    
    
    elapsed_time = end_time - start_time   #calcular tiempo
    print(f"Tiempo total para insertar los datos: {elapsed_time:.2f} segundos")

    
    cursor.close()                      #cerrar el cursor


def getDataframe(csv): #crea el data frame con los subdominios parceados
    df = pd.read_csv(csv, header=None, names=['rank', 'domain'])  
    df[['domain', 'sub2', 'sub3']] = df['domain'].str.split('.', n=2, expand=True)
    
    return df


def getCountriesCodesDict(cursor): #crea el diccionario de codigos de paises
    countriesCodesDict = {}
    
    cursor.execute("SELECT code2, code FROM country")
    countriesCodes = cursor.fetchall()

    for countryCodes in countriesCodes:
        countriesCodesDict[countryCodes[0]] = countryCodes[1]
    
    return countriesCodesDict


def getCountryCode(code, Countriesdict):    #Matchea el cod2 con el cod1 usando CountriesCodesDict incluyendo casos especiales
    codeUp = str(code).upper()
    
    #casos especiales
    if codeUp == "UK" or codeUp == "EU":
        codeUp = "GB"
        return Countriesdict[codeUp]
    
    if codeUp in Countriesdict:
        return Countriesdict[codeUp]

    else:
        codeUp = "US"
        return Countriesdict[codeUp]


def insertValues(cursor, df):
    countriesCodesDict = getCountriesCodesDict(cursor)
    
    for index, row in df.iterrows():
        # Define entidad, tipo_entidad y pais
        id = row['rank']
        entidad = row['domain']
        tipo_entidad = row['sub2']
        countryCode2 = row['sub3']
        
        if countryCode2 is not None:
            countryCode = getCountryCode(countryCode2,countriesCodesDict)
        else:
            countryCode = getCountryCode(tipo_entidad,countriesCodesDict)
        
        # Debug: imprime los valores que se van a insertar
        print(f"Inserting row {index}: {id}, {entidad}, {tipo_entidad}, {countryCode}")
        
        cursor.execute(
            'INSERT INTO sitio (id, entidad, tipo_entidad, countrycode) VALUES (%s, %s, %s, %s)',
            (id, entidad, tipo_entidad, countryCode)
        )


def connect():                  # Conectar a la base de datos
    global connected
    try:
        connection = psycopg2.connect(
            host = 'localhost',
            port = 5432,
            user = 'postgres',
            password = '123',
            database = 'world'
        )
        print("Conexion exitosa")
        connected = True
    except Exception as ex: 
        print(ex)
        connection = ""
        connected = False
    
    return connection


if __name__ == "__main__":
    main()
    
