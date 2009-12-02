package com.edgecase {
  import flash.net.*;
  import flash.external.ExternalInterface;
  import flash.events.*;

  public class FileBrowser {
    public var view:UploadSWFView;
    public var onSelectedCall:String = "s3_swf.onSelected";
    public var model:FilesModel; 

    private var fileReferenceList:FileReferenceList;
    
    public function browse():void{
      fileReferenceList = new FileReferenceList();
      fileReferenceList.addEventListener(Event.SELECT, selectHandler);
      fileReferenceList.addEventListener(Event.CANCEL, cancelHandler);
			fileReferenceList.browse(); // triggers the popup
    }

		private function selectHandler(event:Event):void {
      if(model.files.length == 0){
        view.userMessage.text = ''; // clear the display text if this is the first set of files selected
      }
      for each (var fileReference:FileReference in fileReferenceList.fileList){
        var fileData:S3FileData = new S3FileData(fileReference);
        model.files.push(fileData);
        view.userMessage.text = view.userMessage.text + ' ' + fileData.FileName;
        trace('calling onSelected: '+onSelectedCall+'  '+fileData.FileName+'  '+fileData.FileSize+'  '+fileData.ContentType);
        ExternalInterface.call(onSelectedCall, fileData.FileName, fileData.FileSize, fileData.ContentType);
      }
    }
    
		private function cancelHandler(event:Event):void {
    }
  }
}
