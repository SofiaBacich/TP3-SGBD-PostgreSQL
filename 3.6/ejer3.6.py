import pandas as pd
import psycopg2
import geopandas as gp
import matplotlib.pyplot as plt

#Es necesario correr primero el ejer3.4.sql y el ejer3.4.py para tener la tabla sitio

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
   
    #poblacion
    getGeoDataGraphic(cursor,
                    "Poblacion Mundial", 
                    "SELECT name, population  FROM country", 
                    ['name', 'population'], 
                    'name', 
                    'population')
    
    #producto bruto
    getGeoDataGraphic(cursor,
                    "PBI", 
                    "SELECT name, gnp  FROM country", 
                    ['name', 'gnp'], 
                    'name', 
                    'gnp')
    #sitios web
    getGeoDataGraphic(cursor,
                    "Sitios Web", 
                    "SELECT pais, COUNT(*) AS cantidadSitios FROM sitio GROUP BY pais ORDER BY cantidadSitios DESC;", 
                    ['pais', 'cantidadSitios'], 
                    'pais', 
                    'cantidadSitios')
    
    plt.show()
    
    cursor.close()                      #Cerrar el cursor


def getGeoDataGraphic(cursor,title, sql, columns, mergeCol, geomCol): #creo el data frame con los subdominios parceados
    world = gp.GeoDataFrame.from_file('ne_10m_admin_0_countries.shp')
    #print(world)
    
    world = world.rename(columns = {'SOVEREIGNT':mergeCol})  #Mismo nombre para la columna name o pais
    #print(world)

    world.loc[world[mergeCol] == "United States of America", mergeCol] = "United States" #Caso especial, USA con diferentes nombres

    cursor.execute(sql)
    df = pd.DataFrame(cursor.fetchall(), columns = columns)
    df = df.astype({geomCol:int})       #Nos aseguramos que los datos sean int
 
    df_merged = world.merge(df[columns], on = mergeCol, how = 'left')
    ax = df_merged.plot(column=geomCol, cmap = "turbo", legend=True, missing_kwds={'color': 'lightgrey', 'hatch':'//', 'label':'Missing Values'})

    ax.set_title(title)


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