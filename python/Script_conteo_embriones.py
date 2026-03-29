import os
import glob
import cv2
import numpy as np
import pandas as pd

# Rutas
input_folder = r'C:/Users/Karina/Dropbox/Fondecyt1221210/Fotografias y videos/Loco- Empaq CT etapa 4 Fotos cortadas/Binarizadas/CT065-D0'
output_folder = os.path.join(input_folder, "C:/Users/Karina/Dropbox/Fondecyt1221210/Fotografias y videos/Loco- Empaq CT etapa 4 Fotos cortadas/Contadas/CT065-D0_prueba")
os.makedirs(output_folder, exist_ok=True)

output_csv_folder = r"C:/Users/Karina/Dropbox/Fondecyt1221210/Fotografias y videos/Loco- Empaq CT etapa 4 Fotos cortadas/CSV conteos"

# Buscar imágenes
image_paths = glob.glob(os.path.join(input_folder, "*.jpg"))

# Resultados
resultados = []

for img_path in image_paths:
    image = cv2.imread(img_path)
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    # Umbral binario
    _, binary = cv2.threshold(gray, 127, 255, cv2.THRESH_BINARY)

    # Invertir si es necesario (para que fondo sea 0 y partículas 255)
    binary = cv2.bitwise_not(binary)

    # --- Proceso de separación de partículas con watershed ---

    # Paso 1: Eliminar ruido pequeño
    kernel = np.ones((2, 2), np.uint8)
    opening = cv2.morphologyEx(binary, cv2.MORPH_OPEN, kernel, iterations=1)

    # Paso 2: Asegurar que el fondo es claro (sure background)
    sure_bg = cv2.dilate(opening, kernel, iterations=3)

    # Paso 3: Obtener centros seguros (sure foreground)
    dist_transform = cv2.distanceTransform(opening, cv2.DIST_L2, 5)
    _, sure_fg = cv2.threshold(dist_transform, 0.3 * dist_transform.max(), 255, 0) # si no está tomando todas las particulas debo ajustar valores

    # Paso 4: Regiones desconocidas
    sure_fg = np.uint8(sure_fg)
    unknown = cv2.subtract(sure_bg, sure_fg)

    # Paso 5: Etiquetar marcadores
    _, markers = cv2.connectedComponents(sure_fg)
    markers = markers + 1  # asegurar que el fondo no sea 0
    markers[unknown == 255] = 0

    # Aplicar watershed
    image_watershed = image.copy()
    markers = cv2.watershed(image_watershed, markers)

    # Marcar bordes encontrados por watershed
    image_rgb = cv2.cvtColor(image.copy(), cv2.COLOR_BGR2RGB)
    image_rgb[markers == -1] = [255, 255, 0]  # opcional: pintar bordes en celeste

    # Contar regiones individuales
    unique_labels = np.unique(markers)
    conteo = 0

    for label in unique_labels:
        if label <= 1:
            continue  # 0 = fondo, 1 = unknown

        # Máscara para cada partícula individual
        mask = np.uint8(markers == label)
        contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        for c in contours:
            # Dibujar contorno en azul
            cv2.drawContours(image_rgb, [c], -1, (0, 0, 255), 2)

            # Calcular y dibujar centroide
            M = cv2.moments(c)
            if M["m00"] != 0:
                cx = int(M["m10"] / M["m00"])
                cy = int(M["m01"] / M["m00"])
                cv2.circle(image_rgb, (cx, cy), 4, (255, 0, 0), -1)  # punto rojo

            conteo += 1

    # Guardar imagen de salida
    nombre_salida = os.path.join(output_folder, f"contornos_{os.path.basename(img_path)}")
    cv2.imwrite(nombre_salida, cv2.cvtColor(image_rgb, cv2.COLOR_RGB2BGR))

    # Guardar en resultados
    resultados.append({
        "Foto": os.path.basename(img_path),
        "Conteo": conteo
    })

# Guardar CSV
df_resultados = pd.DataFrame(resultados)
csv_path = os.path.join(output_csv_folder, "CT065-D0_prueba.csv")
df_resultados.to_csv(csv_path, index=False)

print(f"¡Listo! Imágenes marcadas en: {output_folder}")
print(f"Resultados guardados en: {csv_path}")
