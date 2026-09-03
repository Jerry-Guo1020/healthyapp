import { util } from '@kit.ArkUI';
import { fileIo as fs } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';

/**
 * 图片处理工具：相册图片 → 压缩 → base64
 * 用于食物拍照识别的上传前处理（压缩到短边 800 内，避免超大 base64 拖慢识别）
 */
export class ImageUtil {

  /**
   * 读取图片文件字节并转为 base64（含压缩）。
   * 失败时降级为读取原图。
   */
  static async toBase64(uri: string): Promise<string> {
    try {
      const source = image.createImageSource(uri);
      const decodingOptions: image.DecodingOptions = {
        desiredSize: { width: 800, height: 800 }
      };
      const pixelMap = await source.createPixelMap(decodingOptions);
      const packer = image.createImagePacker();
      const packingOptions: image.PackingOption = {
        format: 'image/jpeg',
        quality: 75
      };
      const packed = await packer.packing(pixelMap, packingOptions);
      const helper = new util.Base64Helper();
      return helper.encodeToStringSync(new Uint8Array(packed));
    } catch (e) {
      // 降级：直接读原图
      return ImageUtil.readRaw(uri);
    }
  }

  /** 直接读取原图字节转 base64 */
  static readRaw(uri: string): string {
    const file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
    const stat = fs.statSync(file.fd);
    const buffer = new ArrayBuffer(stat.size);
    fs.readSync(file.fd, buffer);
    fs.closeSync(file);
    const helper = new util.Base64Helper();
    return helper.encodeToStringSync(new Uint8Array(buffer));
  }

}