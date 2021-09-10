all: draft-dickson-dprive-adot-auth.txt draft-dickson-dprive-adot-auth.html

draft-dickson-dprive-adot-auth.txt: draft-dickson-dprive-adot-auth.xml
	xml2rfc --v2 --text draft-dickson-dprive-adot-auth.xml

draft-dickson-dprive-adot-auth.html: draft-dickson-dprive-adot-auth.xml
	xml2rfc --v2 --html draft-dickson-dprive-adot-auth.xml

draft-dickson-dprive-adot-auth.xml: draft-dickson-dprive-adot-auth.md
	./mmark -xml2 -page draft-dickson-dprive-adot-auth.md > draft-dickson-dprive-adot-auth.xml

