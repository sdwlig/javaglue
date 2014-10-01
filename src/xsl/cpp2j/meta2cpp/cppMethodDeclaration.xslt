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
	xmlns:fn="http://www.w3.org/2005/xpath-methods"
	xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
	xmlns:xd="http://www.pnp-software.com/XSLTdoc">

	<xsl:import href="jniMethodSignature.xslt" />
	<xsl:import href="../../util/metaMethodName.xslt" />
	<xsl:import href="jniType.xslt" />

	<xd:doc type="stylesheet">
		<xd:short>Generation of JNI function headers, with javah like comment.</xd:short>
	</xd:doc>


	<xd:doc type="template">
		<xd:short>Creates JNI function declaration with comment.
		</xd:short>
		<xd:param name="config">config file.</xd:param>
		<xd:param name="class_prefix">
			prefix for class name. Contains java package and '$' of inner classes.
		</xd:param>
		<xd:param name="method">meta function element to be processed.</xd:param>
		<xd:param name="class">meta class which contains method.</xd:param>
	</xd:doc>
	<xsl:template name="cppMethodDeclaration">
		<xsl:param name="config" />
		<xsl:param name="class_prefix" />
		<xsl:param name="method" />
		<xsl:param name="class" />

		<!-- check if method is on ignore list -->
		<xsl:if test="not($ignore_list/ignore_list/function
						[. = concat($class/@fullName, '::', $method/name)])">

			<!-- write method comment -->
			<xsl:call-template name="cppMethodDeclarationComment">
				<xsl:with-param name="config" select="$config" />
				<xsl:with-param name="class_prefix" select="$class_prefix" />
				<xsl:with-param name="method" select="$method" />
				<xsl:with-param name="class" select="$class" />
			</xsl:call-template>

			<!-- write real method real declaration -->
			<xsl:call-template name="cppRealMethodDeclaration">
				<xsl:with-param name="config" select="$config" />
				<xsl:with-param name="class_prefix" select="$class_prefix" />
				<xsl:with-param name="method" select="$method" />
				<xsl:with-param name="class" select="$class" />
			</xsl:call-template>

		</xsl:if> <!-- ignore list check -->

	</xsl:template>



	<xd:doc type="template">
		<xd:short>Generate method comments prior method declarations.
		</xd:short>
		<xd:param name="config">config file.</xd:param>
		<xd:param name="class_prefix">
			prefix for class name. Contains java package and '$' of inner classes.
		</xd:param>
		<xd:param name="method">meta function element to be processed.</xd:param>
		<xd:param name="class">meta class which contains method.</xd:param>
	</xd:doc>
	<xsl:template name="cppMethodDeclarationComment">
		<xsl:param name="config" />
		<xsl:param name="class_prefix" />
		<xsl:param name="method" />
		<xsl:param name="class" />

		<!-- shortcut for method name -->
		<xsl:variable name="method_name"
			select="normalize-space($method/name)" />

		<!-- shortcut for method definition -->
		<xsl:variable name="method_def"
			select="normalize-space($method/definition)" />

		<!-- shortcut for class name -->
		<xsl:variable name="class_name"
			select="replace($class_prefix, '_', '.')" />

		<!-- open comment in a single line -->
		<xsl:text>&#10;&#10;/*</xsl:text>

		<!-- write current class name -->
		<xsl:text>&#10;&#32;*&#32;Class:</xsl:text>
		<xsl:text>&#32;&#32;&#32;&#32;&#32;&#32;</xsl:text>
		<xsl:value-of select="$class_name" />

		<!-- write current method name -->
		<xsl:text>&#10;&#32;*&#32;Method:</xsl:text>
		<xsl:text>&#32;&#32;&#32;&#32;&#32;</xsl:text>
		<xsl:value-of select="$method_name" />
		<xsl:text>()</xsl:text>

		<!-- write current method type -->
		<xsl:text>&#10;&#32;*&#32;Type:</xsl:text>
		<xsl:text>&#32;&#32;&#32;&#32;&#32;&#32;&#32;</xsl:text>
		<xsl:choose>
			<xsl:when test="not($method/type)">
				<xsl:text>constructor</xsl:text>
			</xsl:when>
			<xsl:when test="$method/@destructor eq 'true'">
				<xsl:text>destructor</xsl:text>
			</xsl:when>
			<xsl:when test="$method/@public_attribute_getter eq 'true'">
				<xsl:text>getter for public attribute</xsl:text>
			</xsl:when>
			<xsl:when test="$method/@public_attribute_setter eq 'true'">
				<xsl:text>setter for public attribute</xsl:text>
			</xsl:when>
			<xsl:when test="$method/@static eq 'true'">
				<xsl:text>static method</xsl:text>
			</xsl:when>
			<xsl:when test="$method/@virt eq 'virtual'">
				<xsl:text>virtual method</xsl:text>
			</xsl:when>
			<xsl:when test="$method/@virt eq 'pure-virtual'">
				<xsl:text>pure virtual method</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>non-virtual method</xsl:text>
			</xsl:otherwise>
		</xsl:choose>

		<!-- write current method definition -->
		<xsl:text>&#10;&#32;*&#32;Definition:</xsl:text>
		<xsl:text>&#32;</xsl:text>
		<xsl:value-of select="$method_def" />
		<xsl:if test="$method/@public_attribute_getter ne 'true' or $method/@public_attribute_setter ne 'true'">
			<xsl:text>()</xsl:text>
		</xsl:if>

		<!-- write signature of this method -->
		<xsl:text>&#10;&#32;*&#32;Signature:</xsl:text>
		<xsl:text>&#32;&#32;</xsl:text>
		<xsl:call-template name="jniMethodSignature">
			<xsl:with-param name="config" select="$config" />
			<xsl:with-param name="method" select="$method" />
			<xsl:with-param name="class" select="$class" />
		</xsl:call-template>

		<!-- finish comment in a single line -->
		<xsl:text>&#10; */&#10;</xsl:text>

	</xsl:template>


	<xd:doc type="template">
		<xd:short>Generate method declarations.
		</xd:short>
		<xd:param name="config">config file.</xd:param>
		<xd:param name="class_prefix">
			prefix for class name. Contains java package and '$' of inner classes.
		</xd:param>
		<xd:param name="method">meta function element to be processed.</xd:param>
		<xd:param name="class">meta class which contains method.</xd:param>
	</xd:doc>
	<xsl:template name="cppRealMethodDeclaration">
		<xsl:param name="config" />
		<xsl:param name="class_prefix" />
		<xsl:param name="method" />
		<xsl:param name="class" />

		<!-- shortcut for method name -->
		<xsl:variable name="method_name"
			select="normalize-space($method/name)" />

		<!-- shortcut for return type, take long for constructors -->
		<xsl:variable name="return_type"
			select="if($method/type) then normalize-space($method/type) else 'long'" />

		<!-- shortcut for static property -->
		<xsl:variable name="static"
			select="normalize-space($method/@static)" />

		<!-- write export keyword -->
		<xsl:text>&#10;JNIEXPORT</xsl:text>

		<!-- write return type -->
		<xsl:text>&#32;</xsl:text>
		<xsl:choose>
			<xsl:when test="$return_type = 'unsigned long long'">
				<!-- if the returen type is 'unsigned long long', then jlong is used instead of joject -->
				<xsl:text>jlong</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="jniType">
					<xsl:with-param name="config" select="$config" />
					<xsl:with-param name="param" select="$method" />
					<xsl:with-param name="class" select="$class" />				
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>

		<!-- write call method keyword -->
		<xsl:text>&#32;JNICALL</xsl:text>

		<!-- write class name (including JNI header and namespace) -->
		<xsl:text>&#32;Java_</xsl:text>
		<xsl:value-of select="$class_prefix" />
		<xsl:text>_</xsl:text>

		<!-- write parameter meta signature -->
		<xsl:call-template name="metaMethodName">
			<xsl:with-param name="config" select="$config" />
			<xsl:with-param name="method" select="$method" />
			<xsl:with-param name="escape" select="'true'" />
		</xsl:call-template>

		<!-- begin of parameter declaration -->
		<xsl:text>&#32;(</xsl:text>

		<!-- write environment parameter -->
		<xsl:text>&#10;&#32;&#32;</xsl:text>
		<xsl:text>JNIEnv*&#32;</xsl:text>
		<xsl:value-of
			select="$config/config/cpp/variables/jni/environment/@name" />
		<xsl:text>, /* interface pointer */</xsl:text>

		<!-- write object parameter -->
		<xsl:choose>

			<!-- in case of a static method or constructor write class object access -->
			<xsl:when test="($static = 'true') or not($method/type)">
				<!-- write class access parameter -->
				<xsl:text>&#10;&#32;&#32;</xsl:text>
				<xsl:text>jclass&#32;</xsl:text>
				<xsl:value-of
					select="$config/config/cpp/variables/jni/class/@name" />
				<xsl:if test="count(parameters/parameter) &gt; 0">
					<xsl:text>,</xsl:text>
				</xsl:if>
				<xsl:text>&#32;&#32;/* class pointer */</xsl:text>
			</xsl:when>

			<!-- in case of a normal method write object access -->
			<xsl:otherwise>
				<!-- write class access parameter -->
				<xsl:text>&#10;&#32;&#32;</xsl:text>
				<xsl:text>jobject&#32;</xsl:text>
				<xsl:value-of
					select="$config/config/cpp/variables/jni/object/@name" />
				<xsl:text>, /* Java object */</xsl:text>
				<xsl:text>&#10;&#32;&#32;</xsl:text>
				<xsl:text>jlong&#32;</xsl:text>
				<xsl:value-of
					select="$config/config/cpp/variables/jni/pointer/@name" />
				<xsl:if test="count(parameters/parameter) &gt; 0">
					<xsl:text>,</xsl:text>
				</xsl:if>
				<xsl:text>&#32;/* C++ pointer */</xsl:text>
			</xsl:otherwise>

		</xsl:choose>

		<!-- iterator through all parameters -->
		<xsl:for-each select="$method/parameters/parameter">

			<!-- write indent -->
			<xsl:text>&#10;&#32;&#32;</xsl:text>

			<!-- write parameter type -->
			<xsl:call-template name="jniType">
				<xsl:with-param name="config" select="$config" />
				<xsl:with-param name="param" select="." />
				<xsl:with-param name="class" select="$class" />
			</xsl:call-template>

			<!-- seperator type and name -->
			<xsl:text>&#32;</xsl:text>

			<!-- write parameter name -->
			<!-- if there is no param name in original lib -->
			<xsl:variable name="parameterPosition" select="position()"/>
			<xsl:variable name="paramName">
				<xsl:choose>
					<xsl:when test="not(./name) or ./name = ''">
						<xsl:value-of select="concat(
										$config/config/meta/parameter/defaultName,
										$parameterPosition)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="./name"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:value-of select="$paramName" />

			<!-- if another parameter follows, write seperator -->
			<xsl:if test="position()!=last()">
				<xsl:text>,&#32;</xsl:text>
			</xsl:if>

		</xsl:for-each>


		<!-- end of parameter declaration -->
		<xsl:text>&#10;)</xsl:text>

	</xsl:template>

</xsl:stylesheet>
