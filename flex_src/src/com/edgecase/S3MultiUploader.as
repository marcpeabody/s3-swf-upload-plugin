package com.edgecase {
  import flash.net.*;
  import flash.events.*;
  import com.elctech.S3UploadRequest;

  public class S3MultiUploader {

    public var view:UploadSWFView;
    public var SignatureQueryURL:String;
    public var doChecks:String; /* A flag indicating if the s3_uploads_controller should check the file name */
    
    public var model:FilesModel;
    
    public function upload(prefixPath:String):void{
      if (model.files.length == 0) {
        view.error('You need to select a file!');
        return;
      } 
      view.userMessage.text = 'Initiating...';

      var request:URLRequest     = new URLRequest(SignatureQueryURL);
      var loader:URLLoader       = new URLLoader();
      var variables:URLVariables = new URLVariables();
      var count:int = 0;

      for each (var file:S3FileData in model.files){
        trace('OOOOOOOOOOOOO    -  '+prefixPath+file.FileName);

        //variables['file_name[' + count + ']']        = file.FileName;
        variables['file_size[' + count + ']']        = file.FileSize;
        variables['key[' + count + ']']              = prefixPath + file.FileName;
        variables['content_type[' + count + ']']     = file.ContentType;
        variables['do_checks[' + count + ']']        = doChecks;

        count += 1;
      };

      request.method             = URLRequestMethod.GET;
      request.data               = variables;
      loader.dataFormat          = URLLoaderDataFormat.TEXT;

      configureListeners(loader);
      loader.load(request);
    }
    // LISTENERS
		private function completeHandler(event:Event):void {
      var loader:URLLoader = URLLoader(event.target);
      var xml:XML = new XML(loader.data);

      for each(var xmlRecord:XML in xml.child('record')){
        trace(xmlRecord.toString());
        if (xmlRecord.errorMessage != ""){
          view.error("Error: "+xml.errorMessage);
          return;
        }
        var file:S3FileData = model.files[parseInt(xmlRecord.fileindex)];
        file.setOptionsWithXML(xmlRecord);
      }
      sendNextUpload();
		}

    private var uploadIndex:int = 0;
    private function sendNextUpload():void {
      if (uploadIndex < model.files.length){
        var file:S3FileData = model.files[uploadIndex];
        uploadIndex += 1;
        
        // Start post file to S3 //
        var request:S3UploadRequest = new S3UploadRequest(file); 
        request.addEventListener(Event.OPEN, view.startUpload);
        request.addEventListener(ProgressEvent.PROGRESS, view.progress);

        request.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void {
            view.error("Upload Error, please retry.");
        });
        request.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(event:SecurityErrorEvent):void {
            view.error("Upload error, Access denied.");
        });
        request.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, function(event:Event):void {
            view.success(file);
            sendNextUpload();
        });
        try {
            view.userMessage.text = "Uploading commenced...";
            request.upload(file.fileReference);
        } catch(e:Error) {
            view.error(e.toString());
        }
      }
    }
			
    private function openHandler(event:Event):void {
        view.userMessage.text = "Preparing for upload...";
        trace("openHandler: " + event);
    }
    private function progressHandler(event:ProgressEvent):void {
        trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
    }
    private function httpStatusHandler(event:HTTPStatusEvent):void {
        trace("httpStatusHandler: " + event);
    }
    private function securityErrorHandler(event:SecurityErrorEvent):void {
        view.error("Whoa - something went really wrong preparing for upload: securityErrorHandler: " + event);
    }
    private function ioErrorHandler(event:IOErrorEvent):void {
        view.error("Whoa - something went really wrong preparing for upload: ioErrorHandler: " + event);
    }

		private function configureListeners(dispatcher:IEventDispatcher):void {
	    dispatcher.addEventListener(Event.COMPLETE, completeHandler);
			dispatcher.addEventListener(Event.OPEN, openHandler);
	    dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
	    dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
      dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}
  }
}
