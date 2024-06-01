from io import BytesIO

from fastapi import APIRouter, UploadFile, responses, Query
from fastapi.responses import JSONResponse
from rvc.modules.uvr5.modules import UVR
from base64 import b64encode
from scipy.io import wavfile

router = APIRouter()


@router.post("/inference")
def uvr(
    inputpath,
    outputpath,
    modelname,
    res_type: str = Query("blob", enum=["blob", "json"]),
):
    arries = [i for i in UVR()(inputpath, outputpath, model_name=modelname)]
    wavfile.write(wv := BytesIO(), tgt_sr, audio_opt)
    if res_type == "blob":
        return responses.StreamingResponse(
            wv,
            media_type="audio/wav",
            headers={"Content-Disposition": "attachment; filename=inference.wav"},
        )
    else:
        return JSONResponse(
            {
                "audio": b64encode(wv.read()).decode("utf-8"),
            }
        )
