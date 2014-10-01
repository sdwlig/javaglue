<?xml version="1.0" encoding="UTF-8"?>

<!--
	
	This source file is part of XBiG
		(XSLT Bindings Generator)
	For the latest info, see http://sourceforge.net/projects/javaglue
	
	Copyright (c) 2006 The XBiG Development Team
	Also see acknowledgements in Readme.html
	
	This program is free software; you can redistribute it and/or modify it under
	the terms of the GNU Lesser General Public License as published by the Free Software
	Foundation; either version 2 of the License, or (at your option) any later
	version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT
	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
	FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
	
	You should have received a copy of the GNU Lesser General Public License along with
	this program; if not, write to the Free Software Foundation, Inc., 59 Temple
	Place - Suite 330, Boston, MA 02111-1307, USA, or go to
	http://www.gnu.org/copyleft/lesser.txt.
	
	Author: Christoph Nenning
			Kai Klesatschke
	
-->

<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
	xmlns:xd="http://www.pnp-software.com/XSLTdoc"
	xmlns:xbig="http://xbig.sourceforge.net/XBiG"
	xmlns:str="http://exslt.org/strings">

	<xd:doc type="stylesheet">
		<xd:short>
		 This stylesheet provides templates and functions to handle type strings 
		 which include modifieres like 'const' or '*'.
		</xd:short>
	</xd:doc>

	<xd:doc type="template">
		<xd:short>
			Takes a type string with modifiers and creates a Meta-Parameter-Element.
			It is mainly intended to be used for type parameters, e. g. :
			std::list &lt; const A * &gt;.
			Retruned element has a 'passedBy' attribute and a 'type' child element
			which has a 'const' attribute. Unlike in meta.xml that 'const' attribute
			is always present.
		</xd:short>
		<xd:param name="type">Type string to be parsed.</xd:param>
	</xd:doc>
	<xsl:template name="createMetaParameterElement">
		<xsl:param name="type" as="xs:string"/>

			<xsl:variable name="typeBeforeLT" select="if (contains($type, '&lt;')) then
														substring-before($type, '&lt;') else $type"/>

			<xsl:variable name="typeAfterLastGT" select="if (contains($type, '&gt;')) then
														  tokenize($type, '&gt;')[last()] else $type"/>

			<xsl:element name="parameter">
				<!-- set passedBy attribute -->
				<xsl:attribute name="passedBy"
					select="if(matches($typeAfterLastGT,'&amp;')) then
								'reference'
							else if(matches($typeAfterLastGT,'\*')) then
							    'pointer'
							else
							    'value'" />

				<!-- add type child element -->
				<xsl:element name="type">
					<!-- set const attribute -->
					<xsl:attribute name="const"
						select="if(matches($typeBeforeLT,'const ')) then
							     'true'
							   else
							     'false'" />

					<!-- remove all modifiers and spaces -->
					<xsl:variable name="withoutConst"
						select="if(contains($type,'&lt;') and contains($typeBeforeLT,'const ')) then
							     substring-after($typeBeforeLT, 'const ')
							   else if(contains($type,'&lt;')) then
							     $typeBeforeLT
							   else ''"/>
					<xsl:variable name="withoutPtrAndRef"
						select="xbig:removeTypeModifiers($typeAfterLastGT)"/>
					<xsl:variable name="wholeBracket">
						<xsl:choose>
							<xsl:when test="contains($type, '&lt;')">
								<xsl:variable name="bracket"
									select="substring-after($type, '&lt;')" />
								<xsl:variable name="insideBracket">
									<xsl:for-each
										select="tokenize($bracket, '&gt;')[position() != last()]">
										<xsl:value-of select="."/>
										<xsl:value-of select="' &gt;'"/>
									</xsl:for-each>
								</xsl:variable>
								<xsl:value-of select="concat('&lt;', $insideBracket)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="''"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:sequence select="normalize-space(concat(
											$withoutConst, $wholeBracket, $withoutPtrAndRef))" />
				</xsl:element>
			</xsl:element>
	</xsl:template>


	<xd:doc type="function">
		<xd:short>
			Removes all type modifiers with a string and returns the raw
			type name.
		</xd:short>
		<xd:detial>
			Removes all type modifiers with a string and returns the raw
			type name. Modifiers are "&amp;", "*" and "const". Uses the
			XPath function replace(string1, string2, string3, string4) where
			first string is the input, second the regular expression and
			third the string to replace. This function cannot be used for
			types with type parameters.
		</xd:detial>
		<xd:param name="typeString">The string to process.</xd:param>
	</xd:doc>
	<xsl:function name="xbig:removeTypeModifiers" as="xs:string">
		<xsl:param name="typeString" as="xs:string" />

		<xsl:sequence
			select="replace($typeString, '&amp; | \* | const', '', 'x')" />

	</xsl:function>


</xsl:stylesheet>
