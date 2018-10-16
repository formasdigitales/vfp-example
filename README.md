"# vfp-example" 

[logo]: http://formasdigitales.mx/images/github/clientefox.png "Cliente Formas digitales"


```C#
loWSHandler = CREATEOBJECT("WSTimbradoCFDIService","http://dev33.facturacfdi.mx/WSTimbradoCFDIService?wsdl")
leResult = loWSHandler.TimbrarCFDI(cAccesos, utilidades.HtmlEncode(xdoc.xml))
leResultXML.loadXML(leResult)
xmlTimbradoNode = leResultXML.getElementsByTagName('xmlTimbrado').item[0]
thisform.edit1.Value = xmlTimbradoNode.text
```

