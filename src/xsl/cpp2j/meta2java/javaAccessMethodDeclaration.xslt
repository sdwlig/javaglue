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
  
  Author: Frank Bielig
  Christoph Nenning
  
-->

<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
  xmlns:xd="http://www.pnp-software.com/XSLTdoc"
  xmlns:xbig="http://xbig.sourceforge.net/XBiG">

  <xsl:import href="javaType.xslt" />

  <xd:doc type="stylesheet">
    <xd:short>Generation of public java method declarations.</xd:short>
  </xd:doc>

  <xd:doc type="template">
    <xd:short>
      Generates public java method declarations. That means return type,
      method name and parameter list (again types and names).
    </xd:short>
    <xd:param name="config">config file.</xd:param>
    <xd:param name="class">
      class which contains current method.
    </xd:param>
    <xd:param name="method">declaration to be generated.</xd:param>
  </xd:doc>
  <xsl:template name="javaAccessMethodDeclaration">
    <xsl:param name="config" />
    <xsl:param name="class" />
    <xsl:param name="method" />

    <!-- shortcut of function name, rename operators -->
    <xsl:variable name="method_name" select="
				if (starts-with($method/name, 'operator') and not(contains($method/name, '_const')))
				then $config/config/java/operators/op
					[. = normalize-space(substring-after($method/name, 'operator'))]/@javaName
    			else if (starts-with($method/name, 'operator'))
    			then concat($config/config/java/operators/op[. = substring-before(normalize-space(
					substring-after($method/name, 'operator')), '_const')]/@javaName, '_const')
    			else $method/name" />

	<!-- check if method is on ignore list -->
	<xsl:if test="not($ignore_list/ignore_list/function
						[. = concat($class/@fullName, '::', $method/name)])
					  or
					  	$ignore_list/ignore_list/function
						[. = concat($class/@fullName, '::', $method/name)]/@generateDeclaration = 'true'">

	    <!-- shortcut for return type, take long for constructors -->
	    <xsl:variable name="return_type" select="$method/type" />

	    <!-- shortcut for visibility -->
	    <xsl:variable name="visibility" select="$method/@visibility" />

	    <!-- shortcut for static property -->
	    <xsl:variable name="static" select="$method/@static" />

	    <!-- shortcut for virtuality property -->
	    <xsl:variable name="virtuality" select="$method/@virt" />


	    <!-- write method documentation -->
		<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
	    <xsl:text>/**&#32;</xsl:text>
	    <xsl:for-each select="$method/detaileddescription/para">
	      <xsl:text>&#10;</xsl:text>
	      <xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
	      <!-- caused a problem with ogre4j -->
	      <!-- <xsl:value-of select="normalize-space(text())" />-->
	      <xsl:value-of select="text()" />
	    </xsl:for-each>
	    <xsl:text>**/</xsl:text>
	    <xsl:text>&#10;</xsl:text>

    	<!-- write method modifiers -->

	    <!-- write method visibility -->
	    <xsl:if test="$visibility">
	      <xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
	      <xsl:value-of select="$visibility" />
	    </xsl:if>

	    <!-- write static method modifier -->
	    <xsl:if test="$static eq'true'">
	      <xsl:text>&#32;static</xsl:text>
	    </xsl:if>

	    <!-- handle virtual modifiers -->
	    <xsl:choose>

	      <!-- no virtual function -->
	      <xsl:when test="$virtuality eq 'non-virtual'">
	        <xsl:if test="not(empty($return_type))">
	          <!-- generate no final because of interfaces
	            <xsl:text>&#32;final</xsl:text>
	          -->
	        </xsl:if>
	      </xsl:when>

	      <!-- abstract function -->
	      <!-- this is not necessary because of the interfaces 
	        that are generated for multiple inheritance -->
	      <xsl:when test="$virtuality = 'pure-virtual'">
	        <!-- <xsl:text>&#32;abstract</xsl:text> -->
	      </xsl:when>

	      <!-- virtual function -->
	      <xsl:when test="$virtuality = 'virtual'" />

	      <!-- error, not handled type of virtuality -->
	      <xsl:otherwise>
	        <xsl:message terminate="no">
	          ERROR: virtual type '
	          <xsl:value-of select="$virtuality" />
	          ' not allowed.
	        </xsl:message>
	      </xsl:otherwise>
	    </xsl:choose>

		<!-- remember if an object is returned by value -->
		<xsl:variable name="resolvedType" select="if($method/type != '') then
													xbig:resolveTypedef(
													$method/type, $class, $root)
													else 'void'" as="xs:string"/>
		<xsl:variable name="objectReturnedByValue" select="if($method/@passedBy = 'value' and
      						count($config/config/java/types/type[@meta = $resolvedType]) = 0
      						and $config/config/java/passObjectsReturnedByValueAsParameters = 'yes'
      						and not(xbig:isEnum($resolvedType, $class, $root))
      						and not($method/@public_attribute_getter = 'true'
      						 and $method/@static = 'true'))
      						then true() else false()" as="xs:boolean"/>

	    <!-- write return type if available-->
	    <xsl:if test="$return_type">
			<xsl:text>&#32;</xsl:text>

			<!-- objects returned by value must be passed as parameters, 
				 as well as parametrized templates -->
	      	<xsl:choose>
	      		<xsl:when test="$objectReturnedByValue = true() or contains($method/type, '&lt;')">
					<xsl:value-of select="'void'"/>
				</xsl:when>

				<xsl:otherwise>
					<xsl:call-template name="javaType">
						<xsl:with-param name="config" select="$config" />
						<xsl:with-param name="param" select="$method" />
						<xsl:with-param name="class" select="$class" />
						<xsl:with-param name="typeName" select="$return_type" />
						<xsl:with-param name="writingNativeMethod" select="false()" />
						<xsl:with-param name="isTypeParameter" select="false()" />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
	    </xsl:if>

	    <!-- write method name -->
	    <xsl:text>&#32;</xsl:text>
	    <xsl:value-of select="$method_name" />

	    <!-- begin parameter declaration -->
	    <xsl:text>(</xsl:text>

		<!-- generate additional parameter for objects returned by value _or_ parametrized templates -->
		<xsl:if test="$objectReturnedByValue = true() or contains($method/type, '&lt;')">
			<xsl:call-template name="javaType">
				<xsl:with-param name="config" select="$config" />
				<xsl:with-param name="param" select="$method" />
				<xsl:with-param name="class" select="$class" />
				<xsl:with-param name="typeName" select="$return_type" />
				<xsl:with-param name="writingNativeMethod" select="false()" />
				<xsl:with-param name="isTypeParameter" select="false()" />
			</xsl:call-template>
			<xsl:text>&#32;</xsl:text>
			<xsl:value-of select="$config/config/java/returnValueAsParameterName"/>
			<xsl:if test="$method/parameters/parameter">
				<xsl:text>,&#32;</xsl:text>
			</xsl:if>
		</xsl:if>

	    <!-- iterator through all parameters -->
	    <xsl:for-each select="$method/parameters/parameter">

        <!-- write parameter type -->
 	    <xsl:call-template name="javaType">
	            <xsl:with-param name="config" select="$config" />
	            <xsl:with-param name="param" select="." />
	            <xsl:with-param name="class" select="$class" />
	            <xsl:with-param name="typeName" select="./type" />
				<xsl:with-param name="writingNativeMethod" select="false()" />
				<xsl:with-param name="isTypeParameter" select="false()" />
	    </xsl:call-template>

	      <!-- seperator type and name -->
	      <xsl:text>&#32;</xsl:text>

	      <!-- write parameter name -->
	      <!-- if there is no param name in original lib -->
	      <xsl:variable name="parameterPosition" select="position()" />
	      <xsl:variable name="paramName">
	        <xsl:choose>
	          <xsl:when test="not(./name) or ./name = ''">
	            <xsl:value-of
	              select="concat($config/config/meta/parameter/defaultName,
													$parameterPosition)" />
	          </xsl:when>
	          <xsl:otherwise>
	            <xsl:value-of select="./name" />
	          </xsl:otherwise>
	        </xsl:choose>
	      </xsl:variable>
	      <xsl:value-of select="$paramName" />

	      <!-- if another parameter follows, write seperator -->
	      <xsl:if test="position()!=last()">
	        <xsl:text>,&#32;</xsl:text>
	      </xsl:if>

	    </xsl:for-each>

	    <!-- end parameter declaration -->
	    <xsl:text>)</xsl:text>

	</xsl:if> <!-- ignore list check -->

  </xsl:template>

</xsl:stylesheet>
