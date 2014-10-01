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
	xmlns:xd="http://www.pnp-software.com/XSLTdoc">

	<xsl:import href="metaParameterListSignature.xslt" />

	<xd:doc type="stylesheet">
		<xd:short>Changing of method names for meta.</xd:short>
	</xd:doc>

	<xd:doc type="template">
		<xd:short>Change method names to avoid overloading. Needed e.g. for JNI.
		</xd:short>
		<xd:param name="config">config file.</xd:param>
		<xd:param name="method">method to be processed.</xd:param>
		<xd:param name="escape">if set to string 'true', special characters as '_' are masked.</xd:param>
	</xd:doc>
	<xsl:template name="metaMethodName">
		<xsl:param name="config" />
		<xsl:param name="method" />
		<xsl:param name="escape" />

		<!-- shortcut to meta configuration -->
		<xsl:variable name="meta_config" select="$config/config/meta" />

		<!-- shortcut to method name configuration depending on constructor 
			or normal method -->
		<!-- <xsl:variable name="mcfg"
			select="if($method/type) then $meta_config/method/name else $meta_config/constructor/name" />
		 -->
		<xsl:variable name="method_name">
			<xsl:choose>
				<xsl:when test="not($method/type)">
					<xsl:value-of select="concat($meta_config/constructor/name/prefix, 
											$method/name, $meta_config/constructor/name/suffix)" />
				</xsl:when>

				<!-- destructor -->
				<xsl:when test="$method/name = $meta_config/destructor/name">
					<xsl:value-of select="$method/name" />
				</xsl:when>

				<xsl:otherwise>
					<!-- rename operators -->
					<xsl:variable name="method_name" select="
							if (starts-with($method/name, 'operator') and 
								not(contains($method/name, '_const')))
							then $config/config/java/operators/op
								[. = normalize-space(substring-after($method/name, 'operator'))]/@javaName
			    			else if (starts-with($method/name, 'operator'))
			    			then concat($config/config/java/operators/op[. = substring-before(
			    				normalize-space(substring-after($method/name, 'operator')), '_const')]/
			    				@javaName, '_const')
			    			else $method/name" />
					<xsl:value-of select="concat($meta_config/method/name/prefix, 
											$method_name, $meta_config/method/name/suffix)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- write meta signature if parameters available -->
		<xsl:variable name="method_params">
			<xsl:if test="count($method/parameters/parameter) > 0 and
						  (not($method/@public_attribute_setter) or 
						  $method/@public_attribute_setter ne 'true')">

				<!-- write parameter seperation -->
				<xsl:text>__</xsl:text>

				<!-- generate parameter signature list  -->
				<xsl:call-template name="metaParameterListSignature">
					<xsl:with-param name="config" select="$config" />
					<xsl:with-param name="method" select="$method" />
				</xsl:call-template>
			</xsl:if>
		</xsl:variable>

		<!-- create const suffix if special attribute available -->
		<xsl:variable name="const_suffix">
			<xsl:choose>
				<xsl:when test="not($method/@const)">
					<xsl:text></xsl:text>
				</xsl:when>
				<xsl:when test="$method/@const eq 'true'">
					<xsl:text>_const</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text></xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!--<xsl:message>==== DEBUG INFO ====</xsl:message>
		<xsl:message>==== 0. <xsl:value-of select="$method/name/@signature" /> ====</xsl:message>
		<xsl:message>==== DEBUG INFO ====</xsl:message>-->

		<!-- compose full method name -->
		<xsl:variable name="full_method_name">
			<xsl:choose>
				<xsl:when test="$method/name/@signatureAdded">
					<!--<xsl:message>==== DEBUG INFO ====</xsl:message>
					<xsl:message>==== 1. Already has signature ====</xsl:message>
					<xsl:message>==== DEBUG INFO ====</xsl:message>-->
					<xsl:value-of select="concat($method_name, $const_suffix)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($method_name, $method_params, $const_suffix)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>	

		<xsl:choose>
			<xsl:when test="$escape eq 'true'">
				<xsl:value-of
					select="replace($full_method_name, '_', '_1')" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$full_method_name" />
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>



	<xd:doc type="template">
		<xd:short>Generates a meta function element. If a method is overloaded with 'const'
				(void a() vs void a() const) we change it's name (a_const() with default config).
				Return type, parameters and attributes must be copied.
		</xd:short>
		<xd:param name="config">config file.</xd:param>
		<xd:param name="method">method to be processed.</xd:param>
	</xd:doc>
	<xsl:template name="createElementForConstOverloadedMethod">
		<xsl:param name="config" />
		<xsl:param name="method" />

		<xsl:element name="function">
			<xsl:attribute name="virt">
				<xsl:value-of select="$method/@virt" />
			</xsl:attribute>
			<xsl:attribute name="visibility">
				<xsl:value-of select="$method/@visibility" />
			</xsl:attribute>
			<xsl:attribute name="static">
				<xsl:value-of select="$method/@static" />
			</xsl:attribute>
			<xsl:attribute name="const">
				<xsl:value-of select="$method/@const" />
			</xsl:attribute>
			<xsl:attribute name="passedBy">
				<xsl:value-of select="$method/@passedBy" />
			</xsl:attribute>

			<xsl:element name="type">
				<xsl:attribute name="const">
					<xsl:value-of select="$method/type/@const" />
				</xsl:attribute>
				<xsl:attribute name="constPointer">
					<xsl:value-of select="$method/type/@constPointer" />
				</xsl:attribute>
				<xsl:value-of select="$method/type" />
			</xsl:element>
			<xsl:element name="definition">
				<xsl:value-of select="$method/definition" />
			</xsl:element>
			<xsl:element name="name">
				<xsl:value-of select="$config/config/java/constoverloading/prefix" />
				<xsl:value-of select="$method/name" />
				<xsl:value-of select="$config/config/java/constoverloading/suffix" />
			</xsl:element>

			<xsl:element name="parameters">
				<xsl:copy-of select="$method/parameters/*" />
			</xsl:element>

		</xsl:element>

	</xsl:template>


	<xd:doc type="template">
		<xd:short>Change method names to avoid duplicate function definition. Needed e.g. for Java.
		</xd:short>
		<xd:param name="config">config file.</xd:param>
		<xd:param name="method">method to be processed.</xd:param>
	</xd:doc>
	<xsl:template name="createElementForSameInJavaMethod">
		<xsl:param name="config" />
		<xsl:param name="method" />

		<!-- shortcut to meta configuration -->
		<xsl:variable name="meta_config" select="$config/config/meta" />

		<!-- write meta signature if parameters available -->
		<xsl:variable name="method_params">
			<xsl:if test="count($method/parameters/parameter) > 0 and
						  (not($method/@public_attribute_setter) or 
						  $method/@public_attribute_setter ne 'true')">

				<!-- write parameter seperation -->
				<xsl:text>__</xsl:text>

				<!-- generate parameter signature list  -->
				<xsl:call-template name="metaParameterListSignature">
					<xsl:with-param name="config" select="$config" />
					<xsl:with-param name="method" select="$method" />
				</xsl:call-template>
			</xsl:if>
		</xsl:variable>

		<!-- compose full method name -->
		<xsl:variable name="full_method_name"
			select="concat($method/name, $method_params)" />

		<xsl:element name="function">
			<xsl:attribute name="virt">
				<xsl:value-of select="$method/@virt" />
			</xsl:attribute>
			<xsl:attribute name="visibility">
				<xsl:value-of select="$method/@visibility" />
			</xsl:attribute>
			<xsl:attribute name="static">
				<xsl:value-of select="$method/@static" />
			</xsl:attribute>
			<xsl:attribute name="const">
				<xsl:value-of select="$method/@const" />
			</xsl:attribute>
			<xsl:attribute name="passedBy">
				<xsl:value-of select="$method/@passedBy" />
			</xsl:attribute>

			<xsl:element name="type">
				<xsl:attribute name="const">
					<xsl:value-of select="$method/type/@const" />
				</xsl:attribute>
				<xsl:attribute name="constPointer">
					<xsl:value-of select="$method/type/@constPointer" />
				</xsl:attribute>
				<xsl:value-of select="$method/type" />
			</xsl:element>
			<xsl:element name="definition">
				<xsl:value-of select="$method/definition" />
			</xsl:element>
			<xsl:element name="name">
				<xsl:attribute name="signatureAdded">
					<xsl:value-of select="true()" />
				</xsl:attribute>				
				<xsl:value-of select="$full_method_name" />
			</xsl:element>

			<xsl:element name="parameters">
				<xsl:copy-of select="$method/parameters/*" />
			</xsl:element>

		</xsl:element>

	</xsl:template>

</xsl:stylesheet>
