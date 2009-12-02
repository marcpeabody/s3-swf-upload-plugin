package com.edgecase {
  import flash.net.FileReference;
	import com.adobe.net.MimeTypeMap;
  import com.elctech.S3UploadOptions;

  public class S3FileData {
    public var fileReference:FileReference;
    public var file:String;
    public var ContentType:String;
    public var FileName:String;
    public var FileSize:String;
    public var options:S3UploadOptions;
    private var mimeMap:MimeTypeMap = new MimeTypeMap();

    public function S3FileData(fileReference:FileReference) {
      this.fileReference = fileReference;

      this.FileName = fileReference.name.replace(/^.*(\\|\/)/gi, '').replace(/[^A-Za-z0-9\.\-]/gi, '_'); 
      this.FileSize = fileReference.size.toString();
        
      var FileNameArray:Array = this.FileName.split(/\./);
      var FileExtension:String = FileNameArray[FileNameArray.length - 1];
      this.ContentType = mimeMap.getMimeType(FileExtension);
    }

    public function setOptionsWithXML(xmlRecord:XML):void {
      this.options = new S3UploadOptions(xmlRecord);
    }
  }
}
