<div align="center">

<h1>Retrieval-based-Voice-Conversion</h1>
Un framework de conversión de voz basado en VITS y fácil de usar.<br><br>

[![madewithlove](https://img.shields.io/badge/hecho_con-%E2%9D%A4-red?style=for-the-badge&labelColor=orange
)](https://github.com/RVC-Project/Retrieval-based-Voice-Conversion)

<img src="https://counter.seku.su/cmoe?name=rvc&theme=r34" /><br>

[![Licence](https://img.shields.io/github/license/RVC-Project/Retrieval-based-Voice-Conversion?style=for-the-badge)](https://github.com/RVC-Project/Retrieval-based-Voice-Conversion/blob/develop/LICENSE)

[![Discord](https://img.shields.io/badge/Desarrolladores%20de%20RVC-Discord-7289DA?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/HcsmBBGyVk)

</div>

------


> [!NOTE]
> Actualmente en desarrollo... Proporcionado como biblioteca y API en rvc

## Instalación y uso

### Instalación estándar

Primero, cree un directorio en su proyecto. La carpeta `assets` contendrá los modelos necesarios para la inferencia y el entrenamiento, y la carpeta `results` contendrá los resultados del entrenamiento.

```sh
rvc init
```
Esto creará la carpeta `assets` y `.env` en su directorio de trabajo.

> [!WARNING]
> El directorio debe de estar vacío o sin una carpeta de assets.

### Instalación personalizada

Si ya has descargado modelos o deseas cambiar estas configuraciones, edita el archivo `.env`.
Si aún no tienes el archivo `.env`,

```sh
rvc env create
```
puedes crearlo.

Además, para descargar un modelo, puedes utilizar

```sh
rvc dlmodel
```
o
```
rvc dlmodel {download_dir}
```

Finalmente, especifique la ubicación del modelo en el archivo env y estará listo.



### Uso de la librería

#### Inferir un audio
```python
from pathlib import Path

from scipy.io import wavfile

from rvc.modules.vc.modules import VC


def main():
      vc = VC()
      vc.get_vc("{model.pth}")
      tgt_sr, audio_opt, times, _ = vc.vc_inference(
            1, Path("{InputAudio}")
      )
      wavfile.write("{OutputAudio}", tgt_sr, audio_opt)


if __name__ == "__main__":
      main()

```

### Uso en CLI

#### Inferir un audio

```sh
rvc infer -m {model.pth} -i {input.wav} -o {output.wav}
```

| opción        | flag&nbsp; | tipo         | valor por defecto | descipción                                                                                                                                                                                                                                    |
|---------------|------------|--------------|---------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| modelPath     | -m         | Path         | *requerido     | Ruta del modelo o nombre de archivo (se lee en el directorio establecido en env)                                                                                                                                                                                     |
| inputPath     | -i         | Path         | *requerido     | Ruta o carpeta del audio de entrada                                                                                                                                                                                                                     |
| outputPath    | -o         | Path         | *requerido     | Ruta o carpeta del audio de salida                                                                                                                                                                                                                    |
| sid           | -s         | int          | 0             | ID del Orador/ Cantante                                                                                                                                                                                                                              |
| f0_up_key     | -fu        | int          | 0             | Transponer (número entero, número de semitonos, subir una octava: 12, bajar una octava: -12)                                                                                                                                                      |
| f0_method     | -fm        | str          | rmvpe         | Algoritmo de extracción de tono (pm, harvest, crepe, rmvpe)                                                                                                                                                                                          |
| f0_file       | -ff        | Path \| None | None          | Archivo de curva F0 (opcional). Un tono por línea. Reemplaza el F0 predeterminado y la modulación de tono.                                                                                                                                                     |
| index_file    | -if        | Path \| None | None          | Ruta al archivo index de características                                                                                                                                                                                                                 |
| index_rate    | -if        | float        | 0.75          | Proporción de funciones de búsqueda (controla la fuerza del acento, demasiado alta tiene artifacting)                                                                                                                                                                      |
| filter_radius | -fr        | int          | 3             | Si >=3: aplique el filtrado de mediana a los resultados del tono. El valor representa el radio del filtro y puede reducir la respiración                                                                                                               |
| resample_sr   | -rsr       | int          | 0             | Vuelva a muestrear el audio de salida en el posprocesamiento hasta la frecuencia de muestreo final. Establecer en 0 para no remuestreo                                                                                                                                              |
| rms_mix_rate  | -rmr       | float        | 0.25          | Ajuste la escala de la envolvente del volumen. Cuanto más cerca de 0, más imita el volumen de las voces originales. Puede ayudar a enmascarar el ruido y hacer que el volumen suene más natural cuando se establece en un nivel relativamente bajo. Más cerca de 1 habrá un volumen más alto y constante |
| protect       | -p         | float        | 0.33          | Proteja las consonantes sordas y los sonidos respiratorios para evitar artefactos como el desgarro en la música electrónica. Establezca en 0.5 para desactivarlo. Disminuya el valor para aumentar la protección, pero puede reducir la precisión de la indexación                                 |

### Uso de la API
Primero, inicia el servidor.
```sh
rvc-api
```
o
```sh
poetry run poe rvc-api
```

#### Inferir audio

##### Obtener como blob
```sh
curl -X 'POST' \
      'http://127.0.0.1:8000/inference?res_type=blob' \
      -H 'accept: application/json' \
      -H 'Content-Type: multipart/form-data' \
      -F 'modelpath={model.pth}' \
      -F 'input={input audio path}'
```

##### Obtener como json (incluir tiempo)
```sh
curl -X 'POST' \
      'http://127.0.0.1:8000/inference?res_type=json' \
      -H 'accept: application/json' \
      -H 'Content-Type: multipart/form-data' \
      -F 'modelpath={model.pth}' \
      -F 'input={input audio path}'
```

### Uso con Docker

Compilar y ejecutar usando el script:

```bash
./docker-run.sh
```

**O** usar manuálmente:

1. Compilar:

   ```bash
   docker build -t "rvc" .
   ```

2. Ejecutar:

   ```bash
   docker run -it \
     -p 8000:8000 \
     -v "${PWD}/assets/weights:/weights:ro" \
     -v "${PWD}/assets/indices:/indices:ro" \
     -v "${PWD}/assets/audios:/audios:ro" \
     "rvc"
   ```

Recuerda que los pesos (weights), índices y audios de entrada se almacenan en `directorio-actual/assets`
