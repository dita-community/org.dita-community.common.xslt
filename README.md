org.dita-community.common.xslt
==============================

Version: ^version^

Basic support XSLT libraries useful for any XSLT transform:

* relpath_utils.xsl and dita-support-lib.xsl. Intended for use with the DITA Open Toolkit but not limited to that use.
* calculate_map_bos.xsl: Determines the set of files referenced by the input map.
* dita_tidy.xsl: wraps mixed content with the <p> element for all elements identified by the ts:isWrapMixed() boolean function
* resolve-map.xsl: Creates a resolved map with all map references resolved. Not as complete as the Open Toolkit's mapref preprocessing stage but good enough for most applications where you just need a resolved map and aren't worried about branch filtering or metadata propagation.


