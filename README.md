# Ejemplo de timbrado con Visual Fox Pro

![cliente de formas digitales](http://formasdigitales.mx/images/github/clientefox.png)
--

#Requerimientos 
* openssl

 Los pasos para timbrar nuestro cfdi son los siguientes.
* Seleccionamos nuestro archivo de cfdi que esta en excel.
* Seleccionamos nuestro certificado.
* Seleccionamos nuestro archivo key para crear el sello digital.
* Click en sellarxml


##Para obtener la info del certificado 
Utilizaremosla funcion _CFDLeerCertificado_ que viene en el archivo _cfd.prg_ a la cual le enviaremos de parametro el path de nuestro archivo _.cer_ 
```C#
oInfo = CFDLeerCertificado(cArchivoCer)
//Para obtener el serial  
oInfo.Serial
//Para obtener el contenido del certificado 
oInfo.Certificado
```

## Para generar la cadena original 
Debemos crear 2 objetos _MSXML2.DOMdocument_ uno que sera nuestro cfdi y el otro que contendra el _xslt_ para poder generar la cadena original de nuestro xml.
```C#
xstyleDoc = NEWOBJECT('MSXML2.DOMdocument')
xdoc=NEWOBJECT('MSXML2.DOMdocument')
cArchivoXML = thisform.txtxML.Value
xdoc.LOAD(cArchivoXML)

xstyleDoc.LOAD('SSL/cadenaoriginal_3_3.xslt')
xstyleDoc.async = 0
xstyleDoc.resolveExternals = 1
xstyleDoc.validateOnParse = 1

cadenaOriginal = xdoc.transformNode(xstyleDoc)
```

## Para generar el sello
Utilizaremos la funcion _CFDGenerarSello_ que viene el archivo _cfd.prg_, al cual le pasamos la cadena original, la ruta del nuestro archivo Key, el password del Key y el metodo de encriptado en este caso es _sha256_
```C#
cSello = CFDGenerarSello(cadenaOriginal , cArchivoKey , '12345678a', 'sha256')
```

## Para Timbrar con el webservice
Creamos un objeto _accesos_  por default el usuario y password es _PruebasWS_ le puedes asignar otros valores o los correspondientes segun tu usuario password, tambien creamos un objeto _WSTimbradoCFDIService_ que es el encargado de consumir nuestro webservice para timbrar hacemos la llamada a la funcion _TimbrarCFDI_ a la cual le pasaremos de parametros el objeto accesos y nuestro xml convertido en string lo cual lo haremos con la funcion _HtmlEncode_.
```C#
cAccesos = NEWOBJECT('accesos')
loWSHandler = CREATEOBJECT("WSTimbradoCFDIService","http://dev33.facturacfdi.mx/WSTimbradoCFDIService?wsdl")
leResult = loWSHandler.TimbrarCFDI(cAccesos, utilidades.HtmlEncode(xdoc.xml))
leResultXML.loadXML(leResult)
xmlTimbradoNode = leResultXML.getElementsByTagName('xmlTimbrado').item[0]
thisform.edit1.Value = xmlTimbradoNode.text
```
Si todo es correcto el webservice nos retornara un nodo llamado _xmlTimbrado_ el cual contiene nuestro cfdi timbrado.

