DEFINE CLASS utilidades as Custom

FUNCTION formatdate(dateTimeValue)
IF EMPTY(dateTimeValue)
           RETURN ""
          ENDIF
RETURN STR(YEAR(dateTimeValue),4) + "-" + PADL(MONTH(dateTimeValue),2,"0") + "-" + PADL(DAY(dateTimeValue),2,"0") + "T" + ;
                 PADL(HOUR(dateTimeValue),2,"0") + ":" + PADL(MINUTE(dateTimeValue),2,"0") + ":" + PADL(SEC(dateTimeValue),2,"0")
ENDFUNC

 *---------------------------------------------------
 FUNCTION HtmlEncode(lsText as String)
 local lsReturn as String
 try
   lsReturn = strtran(lsText,[&],[&amp;])
   lsReturn = strtran(lsReturn,[<],[&lt;])
   lsReturn = strtran(lsReturn,[>],[&gt;])
   lsReturn = strtran(lsReturn,	["],[&quot;])
   lsReturn = strtran(lsReturn,['],[&apos;])
   * You can add more to escape
 catch to loe

  lsReturn = ""
  throw loe
 endtry
 return lsReturn
endfunc && HtmlEncode

Function HtmlDecode(lsText as String)
 local lsReturn as String
 try
   lsReturn = strtran(lsText,[&lt;],[<])
   lsReturn = strtran(lsReturn,[&gt;],[>])
   lsReturn = strtran(lsReturn,[&quot;],["])
   lsReturn = strtran(lsReturn,[&apos;],['])
   lsReturn = strtran(lsReturn,[&amp;],[&])
   * You can add more to escape
 catch to loe
  lsReturn = ""
  throw loe
 endtry
 return lsReturn
EndFun && HtmlDecode

ENDDEFINE


DEFINE CLASS accesos as Custom
*
usuario = "pruebasWS"
password = "pruebasWS"
*
ENDDEFINE

DEFINE CLASS Parametros as Custom
comprobante = ""
accesos = NULL
ENDDEFINE


DEFINE CLASS WSTimbradoCFDIService as Custom

* --- Definimos las propiedades ---
 sError = ""
 iStatus = 0 
 sURL_WS = ""
*-----------------*

*---------------------------------------------------
 FUNCTION EjecutaWS(pURL_WSDL, pFileRequest , pFileResponse )
 *---------------------------------------------------
    TRY 
     oHTTP = CREATEOBJECT('Msxml2.ServerXMLHTTP.6.0')
     oHTTP.OPEN("POST", pURL_WSDL, .F.)
     oHTTP.setRequestHeader("User-Agent", "Ejecutando WS")
     oHTTP.setRequestHeader("Content-Type", "text/xml;charset=utf-8")
     oHTTP.SEND(pFileRequest)
    CATCH TO loErr
      this.sError = "Error: " + TRANSFORM(loErr.ErrorNo) +  " Mensaje: " + loErr.Message
      this.iStatus = -1      
    ENDTRY 
    IF this.iStatus != 0
     RETURN -1
    ENDIF 
     * --- Si el status es diferente a 200, ocurrió algún error de conectividad con el WS ---
     IF oHTTP.STATUS = 200
         RespuestaWS = oHTTP.responseText
      * --- Se genera el XML del response | Este es el paso 3!! ---
      STRTOFILE(STRCONV(RespuestaWS,9),pXMLResponse)
      this.iStatus = 0
      this.sError = ""
      RETURN 0
     ELSE
         this.sError = "Error: No se logró la conexión con el Web Service."
         this.iStatus = -1
   RETURN -1
     ENDIF
 ENDFUNC 

FUNCTION TimbrarCFDI(accesos, xmlString)
sXMLRequest = this.CREATETimbrarCFDI(accesos, xmlString)

pXMLResponse = ADDBS(SYS(2023)) + SYS(2015) + [.xml]
  
  * --- Paso 2. Ejecuto el WS | Paso 3. Obtengo el Response ---
  this.iStatus =  this.EjecutaWS( this.sURL_WS, sXMLRequest , pXMLResponse )

  IF this.iStatus != 0  && Ocurrió un error el cual está especificado en sError.
   RETURN this.sError
  ENDIF 
  
  sXMLResponse = FILETOSTR(pXMLResponse)
  this.borraArchivo(pXMLResponse)
  
  RETURN sXMLResponse 


ENDFUNC

FUNCTION CREATETimbrarCFDI(accesos, xmlString)
TEXT TO xmlRequest TEXTMERGE NOSHOW
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wser="http://wservicios/">
   <soapenv:Header/>
   <soapenv:Body>
      <wser:TimbrarCFDI>
         <accesos>
            <password><<accesos.password>></password>
            <usuario><<accesos.usuario>></usuario>
         </accesos>
         <comprobante><<xmlString>></comprobante>
      </wser:TimbrarCFDI>
   </soapenv:Body>
</soapenv:Envelope>
ENDTEXT
RETURN xmlRequest 
ENDFUNC

 *---------------------------------------------------
 FUNCTION BorraArchivo(pFile)
 *---------------------------------------------------
  IF FILE(pFile)
   DELETE FILE (pFile)
  ENDIF 
 ENDFUNC 
 *---------------------------------------------------

 *---------------------------------------------------
 * Evento constructor
 PROCEDURE Init(tcURLWS)
 *---------------------------------------------------
        this.sURL_WS = tcURLWS
        this.iStatus = 0
        this.sError = ""
 ENDPROC



ENDDEFINE




