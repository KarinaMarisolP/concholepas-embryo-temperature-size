// Definir las rutas de entrada y salida
inputDirectory = "C:/Users/Karina/Dropbox/Fondecyt 1221210 -Cuidado parental/Fotografias y videos/Pruebas grilla/cortadas"; // Cambiar por la ruta de entrada
outputDirectory = "C:/Users/Karina/Dropbox/Fondecyt 1221210 -Cuidado parental/Fotografias y videos/Pruebas grilla/cortadas/procesadas_2"; // Cambiar por la ruta de salida

// Crear la carpeta de salida si no existe
if (!File.exists(outputDirectory)) {
    File.makeDirectory(outputDirectory);
}

// Obtener la lista de archivos en la carpeta de entrada
files = getFileList(inputDirectory);

// Procesar cada archivo de imagen
for (i = 0; i < files.length; i++) {
    fileName = files[i];
    filePath = inputDirectory + "/" + fileName;

    // Filtrar solo archivos de imagen
    if (!endsWith(fileName, ".jpg") && !endsWith(fileName, ".png") && !endsWith(fileName, ".tif") && !endsWith(fileName, ".bmp")) {
        continue;
    }

    print("Procesando: " + fileName);

    // Abrir la imagen
    open(filePath);

    // Dividir canales y usar el primer canal (azul en este caso)
    //run("RGB Color");
    run("Split Channels");
    selectWindow(fileName + " (blue)");
    close(fileName + " (green)");
    close(fileName + " (red)");
    
    //run("Gaussian Blur...", "sigma=1");
    run("Median...", "radius=2"); // Quita ruido tipo sal y pimienta  #NUEVO
    
    //run("Subtract Background...", "rolling=100 light");  // #NUEVO AJUSTAR ANTES 


        // Configurar umbral automático (ajustable manualmente si es necesario)
        run("Auto Local Threshold", "method=Sauvola radius=91 parameter_1=0.34 white"); // radius es tamaño de vecindario en pixeles (radio en pixeles). Radio mas pequeño, mas sensible a detalles y ruido
        //Valor de k , es valor de sensibilidad , mas bajo mas inclusivo, más alto más estricto

        run("Convert to Mask");

        //run("Watershed");   -------------------- tener ojo, ya que colocar watershed antes de los filtros morfologicos puede causar sobrefragmentacion

        // Filtros morfológicos
        //run("Morphological Filters", "operation=[External Gradient] element=Disk radius=2");
        run("Morphological Filters", "operation=[Opening] element=Disk radius=1");
        
        // Aplicar otros pasos de procesamiento
        //run("Find Edges");
        //run("Outline");
        //run("Dilate");
        //run("Kill Borders");
        run("Fill Holes");
        run("Watershed");
        //run("Kill Borders");
        

        // Análisis de partículas (sin guardar .csv)
        run("Analyze Particles...", "size=400-Infinity show=[Masks]  clear overlay");
        //run("Analyze Particles...", "size=500-Infinity circularity=0.40-1.00 show=[Masks]  clear overlay");
        //run("Analyze Particles...", "size=600-Infinity  show=[Overlay]  clear overlay");
        
        
        //run("Convert to Mask"); // Convertir la imagen a máscara binaria

       // Invertir los colores: fondo negro y partículas blancas
       // run("Invert");

        

        // Guardar solo la imagen final en formato JPEG
        outputImage = outputDirectory + "/processed_" + replace(fileName, ".jpg", ".jpg");
        saveAs("Jpeg", outputImage);
        print("Guardado: " + outputImage);

    // Cerrar todas las ventanas para evitar conflictos
    close("*");
}

print("Procesamiento completado.");
