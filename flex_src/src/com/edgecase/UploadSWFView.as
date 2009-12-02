package com.edgecase {
  import flash.net.*;
  import mx.controls.*;
  import flash.events.*;
  import com.edgecase.S3FileData;
  import flash.external.ExternalInterface;

  public class UploadSWFView {
    public var onSuccessCall:String  = "s3_swf.onSuccess";
    public var onFailedCall:String   = "s3_swf.onFailed";
    public var onCancelCall:String   = "s3_swf.onCancel";

    public var userMessage:Label;
    public var uploadProgressBar:ProgressBar;
    public var selectButton:Button;


    public function error(text:String):void {
      uploadProgressBar.visible = false;
      selectButton.visible = true;
      userMessage.visible = true;
      userMessage.text = text;
      userMessage.setStyle("color","#770000");
      ExternalInterface.call(onFailedCall);
      trace(text);
    }

    public function progress(event:ProgressEvent):void {
      var penct:uint = uint(event.bytesLoaded / event.bytesTotal * 100);
      uploadProgressBar.label = 'Uploading ' + penct + " %";
      uploadProgressBar.setProgress(event.bytesLoaded, event.bytesTotal);
    }
    public function startUpload(event:Event):void {
      userMessage.text = "";
      uploadProgressBar.label = 'Uploading'
      uploadProgressBar.visible = true;
      selectButton.visible = false;
    }
    public function success(file:S3FileData):void {
      uploadProgressBar.visible = false;
      selectButton.visible = true;
      userMessage.text = "Upload complete!";
      trace('^^^^^^   '+file.FileName);
      trace('calling onSuccess: '+onSuccessCall+'  '+file.FileName+'  '+file.FileSize+'  '+file.ContentType);
      ExternalInterface.call(onSuccessCall, file.FileName, file.FileSize, file.ContentType);
    }
  }
}
