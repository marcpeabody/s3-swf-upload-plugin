package com.elctech {

    public class S3UploadOptions {
    	/**
       * Options specified at:
       * http://docs.amazonwebservices.com/AmazonS3/2006-03-01/HTTPPOSTForms.html
       */
      public var AWSAccessKeyId:String;
      public var acl:String;
      public var bucket:String;
      public var CacheControl:String;
      public var ContentDisposition:String;
      public var ContentEncoding:String;
      public var Expires:String;
      public var key:String;
      public var policy:String;
      public var successactionredirect:String;
      public var redirect:String;
      public var successactionstatus:String;
      public var signature:String;
      public var xamzsecuritytoken:String;
      
      public var Secure:String;           /* A flag indicating whether HTTPS should be used. */

      public function S3UploadOptions(xmlRecord:XML){
        trace('S3UploadOptions constructor'+xmlRecord.key);
        this.key            = xmlRecord.key;
        this.policy         = xmlRecord.policy;
        this.signature      = xmlRecord.signature;
        this.bucket         = xmlRecord.bucket;
        this.AWSAccessKeyId = xmlRecord.accesskeyid;
        this.acl            = xmlRecord.acl;
        this.Expires        = xmlRecord.expirationdate;
        this.Secure         = xmlRecord.https;
      }
    }
}
