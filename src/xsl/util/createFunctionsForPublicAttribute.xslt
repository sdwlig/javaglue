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
		<xd:short>Creates two meta function elements for a public attribute. 
				  One to set it's value and one to get it.</xd:short>
	</xd:doc>

	<xd:doc type="template">
		<xd:short>Generates functions to set and get values of variable elements. For const
				attributes only a getter is generated.
		</xd:short>
		<xd:param name="variable">Meta element to which functions shall be created.</xd:param>
	</xd:doc>
	<xsl:template name="createFunctionsForPublicAttribute">
		<xsl:param name="variable" />

		<!-- getter -->
		<xsl:element name="function">
			<xsl:attribute name="public_attribute_getter">
				<xsl:text>true</xsl:text>
			</xsl:attribute>
			<xsl:attribute name="virt">
				<xsl:text>non-virtual</xsl:text>
			</xsl:attribute>
			<xsl:attribute name="visibility">
				<xsl:text>public</xsl:text>
			</xsl:attribute>
			<xsl:attribute name="static">
				<xsl:value-of select="$variable/@static" />
			</xsl:attribute>
			<xsl:attribute name="const">
				<xsl:value-of select="$variable/@const" />
			</xsl:attribute>
			<xsl:attribute name="passedBy">
				<xsl:value-of select="$variable/@passedBy" />
			</xsl:attribute>
			<xsl:element name="attribute_name">
				<xsl:value-of select="$variable/name"/>
			</xsl:element>
			<xsl:element name="type">
			  <xsl:attribute name="pointerPointer" select="$variable/type/@pointerPointer"/>
				<!-- for primitive types as template parameters -->
				<xsl:if test="$variable/type/@originalType">
					<xsl:attribute name="originalType" select="$variable/type/@originalType"/>
				</xsl:if>
				<xsl:value-of select="$variable/type" />
			</xsl:element>
			<xsl:element name="name">
				<!-- <xsl:value-of> Usage error, must have select. -->
					<!-- <xsl:value-of select="'__'"/> -->
					<xsl:value-of select="$config/config/meta/publicattribute/get/text()"/>
					<xsl:value-of select="$variable/name"/>
				<!-- </xsl:value-of> -->
			</xsl:element>
			<xsl:element name="definition">
				<xsl:value-of select="$variable/definition" />
			</xsl:element>
		</xsl:element>

		<!-- addrgetter -->
		<!--
		<xsl:element name="function">
			<xsl:attribute name="public_attribute_addrgetter">
				<xsl:text>true</xsl:text>
			</xsl:attribute>
			<xsl:attribute name="virt">
				<xsl:text>non-virtual</xsl:text>
			</xsl:attribute>
			<xsl:attribute name="visibility">
				<xsl:text>public</xsl:text>
			</xsl:attribute>
			<xsl:attribute name="static">
				<xsl:value-of select="$variable/@static" />
			</xsl:attribute>
			<xsl:attribute name="const">
				<xsl:value-of select="$variable/@const" />
			</xsl:attribute>
			<xsl:attribute name="passedBy">
				<xsl:value-of select="$variable/@passedBy" />
			</xsl:attribute>
			<xsl:element name="attribute_name">
				<xsl:value-of select="$variable/name"/>
			</xsl:element>
			<xsl:element name="type">
			  <xsl:attribute name="pointerPointer" select="$variable/type/@pointerPointer"/>
				<xsl:if test="$variable/type/@originalType">
					<xsl:attribute name="originalType" select="$variable/type/@originalType"/>
				</xsl:if>
				<xsl:value-of select="$variable/type" />
			</xsl:element>
			<xsl:element name="name">
					<xsl:value-of select="$config/config/meta/publicattribute/getaddr/text()"/>
					<xsl:value-of select="$variable/name"/>
			</xsl:element>
			<xsl:element name="definition">
				<xsl:value-of select="$variable/definition" />
			</xsl:element>
		</xsl:element>
		-->

		<!-- setter -->
		<xsl:if test="$variable/type/@const != 'true' or not($variable/type/@const)">
			<xsl:element name="function">
				<xsl:attribute name="public_attribute_setter">
					<xsl:text>true</xsl:text>
				</xsl:attribute>
				<xsl:attribute name="virt">
					<xsl:text>non-virtual</xsl:text>
				</xsl:attribute>
				<xsl:attribute name="visibility">
					<xsl:text>public</xsl:text>
				</xsl:attribute>
				<xsl:attribute name="static">
					<xsl:value-of select="$variable/@static" />
				</xsl:attribute>
				<xsl:attribute name="const">
					<xsl:value-of select="$variable/@const" />
				</xsl:attribute>
				<xsl:attribute name="passedBy">
					<!-- <xsl:value-of select="$variable/@passedBy" /> -->
					<xsl:value-of select="'value'" />
				</xsl:attribute>
				<xsl:element name="attribute_name">
					<xsl:value-of select="$variable/name"/>
				</xsl:element>
				<xsl:element name="type">
					<xsl:text>void</xsl:text>
				</xsl:element>
				<xsl:element name="name">
					<!-- <xsl:value-of> Usage error, must have select. -->
						<!-- <xsl:value-of select="'__'"/> -->
						<xsl:value-of select="$config/config/meta/publicattribute/set/text()"/>
						<xsl:value-of select="$variable/name"/>
					<!-- </xsl:value-of> -->
				</xsl:element>
				<xsl:element name="definition">
					<xsl:value-of select="$variable/definition" />
				</xsl:element>
				<xsl:element name="parameters">
					<xsl:element name="parameter">
						<xsl:attribute name="passedBy">
							<xsl:value-of select="$variable/@passedBy" />
						</xsl:attribute>
						<xsl:element name="type">
						  <xsl:attribute name="pointerPointer" select="$variable/type/@pointerPointer"/>
							<!-- for primitive types as template parameters -->
							<xsl:if test="$variable/type/@originalType">
								<xsl:attribute name="originalType" select="$variable/type/@originalType"/>
							</xsl:if>
							<xsl:value-of select="$variable/type" />
						</xsl:element>
						<xsl:element name="name">
							<xsl:value-of select="$config/config/cpp/variables/jni/attributevalue/@name" />
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if>

	</xsl:template>
</xsl:stylesheet>
