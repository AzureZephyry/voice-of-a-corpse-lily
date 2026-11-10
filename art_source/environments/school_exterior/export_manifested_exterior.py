"""Extract the saved artist projection and source board alpha; never write the KRA."""
import io, json, zipfile, hashlib
import xml.etree.ElementTree as ET
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[3]
SOURCE=Path(__file__).with_name("school_exterior_manifested.kra")
OUT=ROOT/"assets/environments/school_exterior/composite"
def decompress(data):
    output=bytearray(); i=0
    while i<len(data):
        control=data[i]; i+=1
        if control<32:
            output.extend(data[i:i+control+1]); i+=control+1
        else:
            count=control>>5; start=len(output)-((control&31)<<8)-1
            if count==7: count+=data[i]; i+=1
            start-=data[i]; i+=1
            for k in range(count+2): output.append(output[start+k])
    return bytes(output)
def board_alpha(archive):
    stream=io.BytesIO(archive.read("Unnamed/layers/layer18"))
    assert stream.readline()==b"VERSION 2\n"
    assert stream.readline()==b"TILEWIDTH 64\n"
    assert stream.readline()==b"TILEHEIGHT 64\n"
    assert stream.readline()==b"PIXELSIZE 4\n"
    count=int(stream.readline().split()[1]); alpha=Image.new("L",(1455,1467))
    for _ in range(count):
        x,y,codec,size=stream.readline().decode().strip().split(",")
        assert codec=="LZF"
        compressed=stream.read(int(size)); assert compressed[0]==1
        raw=decompress(compressed[1:]); assert len(raw)==16384
        alpha.paste(Image.frombytes("L",(64,64),raw[12288:]),(int(x),int(y)))
    return alpha
if __name__=="__main__":
    before=hashlib.sha256(SOURCE.read_bytes()).hexdigest()
    with zipfile.ZipFile(SOURCE) as archive:
        assert archive.testzip() is None
        document=ET.fromstring(archive.read("maindoc.xml"))
        board=next(n for n in document.iter() if n.attrib.get("uuid")=="{cf95a0f1-e409-4989-bf96-8c7d037f3e3a}")
        assert board.attrib["filename"]=="layer18" and board.attrib["visible"]=="1"
        composite=archive.read("mergedimage.png")
        assert Image.open(io.BytesIO(composite)).size==(1455,1467)
        alpha=board_alpha(archive)
    (OUT/"school_manifested_saved_composite.png").write_bytes(composite)
    mask=Image.open(OUT/"school_notice_board_occlusion_mask.png").convert("RGBA")
    pixels=mask.load()
    for y in range(mask.height):
        for x in range(mask.width):
            if pixels[x,y][3]==33: pixels[x,y]=(0,0,0,0)
    stamp=Image.new("RGBA",mask.size); stamp.putalpha(alpha.point(lambda a:33 if a else 0))
    mask.paste(stamp,(0,0),alpha.point(lambda a:255 if a else 0))
    mask.paste((0,0,0,0),(688,1096,727,1155))
    mask.save(OUT/"school_manifested_occlusion_mask.png")
    assert before==hashlib.sha256(SOURCE.read_bytes()).hexdigest()
    contract={"source_sha256":before,"composite_sha256":hashlib.sha256(composite).hexdigest(),"method":"embedded saved composite; not a fresh Krita export","board_bbox":alpha.getbbox(),"board_alpha":"original 8-bit KRA layer18 LZF tiles, planar alpha","other_depth":"existing shared architectural occlusion geometry; added corruption depth needs artist review"}
    (OUT/"school_manifested_export_contract.json").write_text(json.dumps(contract,indent=2),encoding="utf-8")
    print(json.dumps(contract))
