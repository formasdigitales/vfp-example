# Ejemplo de timbrado con Visual Fox Pro

![cliente de formas digitales](http://formasdigitales.mx/images/github/clientefox.png)
Los pasos para timbrar nuestro cfdi son los siguientes.
* Seleccionamos nuestro archivo de cfdi que esta en excel.
* Seleccionamos nuestro certificado.
* Seleccionamos nuestro archivo key para crear el sello digital.


```C#
loWSHandler = CREATEOBJECT("WSTimbradoCFDIService","http://dev33.facturacfdi.mx/WSTimbradoCFDIService?wsdl")
leResult = loWSHandler.TimbrarCFDI(cAccesos, utilidades.HtmlEncode(xdoc.xml))
leResultXML.loadXML(leResult)
xmlTimbradoNode = leResultXML.getElementsByTagName('xmlTimbrado').item[0]
thisform.edit1.Value = xmlTimbradoNode.text
```

