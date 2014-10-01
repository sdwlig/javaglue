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
	
	Author: Kai Klesatschke
			Christoph Nenning
	
-->

<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
	xmlns:xd="http://www.pnp-software.com/XSLTdoc"
	xmlns:xbig="http://xbig.sourceforge.net/XBiG">

	<xsl:import href="../../util/metaInheritedMethods.xslt" />

	<xd:doc type="stylesheet">
		<xd:short>
			Collection of utilities specialized for Java output.
		</xd:short>
	</xd:doc>

	<xd:doc type="template">
		<xd:short>
			Takes a list of functions and returns a filtered list which
			is valid for Java.
		</xd:short>
		<xd:param name="functionNodeList">method list to be filtered.</xd:param>
	</xd:doc>
	<xsl:template name="getValidMethodList">
		<xsl:param name="functionNodeList" />

		<xsl:for-each select="$functionNodeList/function">
			<xsl:variable name="currentMethod" select="." />
			<xsl:variable name="currentMethodPos" select="position()" />
			<xsl:choose>

				<!-- filter duplicate methods -->
				<xsl:when
					test="count(../function[name = $currentMethod/name]) > 1">

					<!-- check for each method with the same name if it is equal -->
					<xsl:variable name="equalSiblings">
						<xsl:for-each
							select="../function[name = $currentMethod/name]">
							<xsl:if
								test="count(. | $currentMethod) != 1">
								<!-- here I use the trick with count() and the union operator (|) to test a node's identity -->
								<xsl:element name="check">
									<xsl:choose>
										<xsl:when
											test="xbig:areTheseMethodsEqual($currentMethod, .,true())">
											<xsl:value-of
												select="true()" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of
												select="false()" />
										</xsl:otherwise>
									</xsl:choose>
								</xsl:element>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>

					<!-- filter method if there is at least one other equal -->
					<xsl:choose>
						<xsl:when test="$equalSiblings/* = true()">
							<!-- OK, we know this method is duplicate, but we have to generate it once -->
							<!-- again the id trick -->
							<!-- we must take the first one, to use the correct class name in JNI for multiple inheritance -->
							<xsl:if
								test="count(../function[name = $currentMethod/name][@const = $currentMethod/@const][position() = 1] | $currentMethod) = 1">
								<xsl:copy-of select="." />
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<xsl:copy-of select="." />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>

				<!-- return relevant methods -->
				<xsl:otherwise>
					<xsl:copy-of select="." />
				</xsl:otherwise>

			</xsl:choose>
		</xsl:for-each>
	</xsl:template>


	<xd:doc type="function">
		<xd:short>
			Takes a fully qualified C++ namespace and returns the almost fully qualified Java package.
			Only the configurable prefix is missing.
		</xd:short>
		<xd:param name="namespace">C++ namespace to be checked.</xd:param>
		<xd:param name="config">config.xml file, contains namespace mapping.</xd:param>
	</xd:doc>
	<xsl:function name="xbig:getJavaPackageName" as="xs:string">
		<xsl:param name="namespace" as="xs:string" />
		<xsl:param name="config" />

		<xsl:sequence select="if($config/config/java/namespaces/rename[. = $namespace])
								then $config/config/java/namespaces/rename[. = $namespace]/@package
								else replace($namespace, '::', '.')"/>

	</xsl:function>


	<xd:doc type="function">
		<xd:short>
			Takes a fully qualified C++ namespace and returns the _not_ fully qualified Java package.
			Needed in javaType.xslt.
		</xd:short>
		<xd:param name="namespace">C++ namespace to be checked.</xd:param>
		<xd:param name="config">config.xml file, contains namespace mapping.</xd:param>
	</xd:doc>
	<xsl:function name="xbig:getUnqualifiedJavaPackageName" as="xs:string">
		<xsl:param name="namespace" as="xs:string" />
		<xsl:param name="config" />

		<xsl:variable name="prefixedNamespace" select="if (not(contains($namespace, '::')))
									then concat('::', $namespace) else $namespace"/>

		<xsl:sequence select="if(not($config/config/java/namespaces/rename[. = $namespace]))
								then tokenize($prefixedNamespace, '::')[last()]
								else if (not(contains($config/config/java/namespaces/rename
										[. = $namespace]/@package, '.')))
								then $config/config/java/namespaces/rename
										[. = $namespace]/@package
								else tokenize($config/config/java/namespaces/rename
										[. = $namespace]/@package, '\.')[last()]"/>

	</xsl:function>

</xsl:stylesheet>
