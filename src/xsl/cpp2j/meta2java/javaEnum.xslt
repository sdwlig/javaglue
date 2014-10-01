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
	xmlns:xd="http://www.pnp-software.com/XSLTdoc">

	<xd:doc type="stylesheet">
		<xd:short>Generation of enumerations</xd:short>
	</xd:doc>

	<xd:doc type="template">
		<xd:short>
			Generates a java enumeration with helper class. Works for
			enums in namespaces and classes/structs.
		</xd:short>
		<xd:param name="enum">enum to process.</xd:param>
		<xd:param name="buildFile">
			ant build.xml file. Needed for project name in static
			initializer of helper class.
		</xd:param>
		<xd:param name="libName">
			libName Needed for project name in static
			initializer.
		</xd:param>
	</xd:doc>
	<xsl:template name="javaEnum">
		<xsl:param name="enum" />
		<xsl:param name="buildFile" />
		<xsl:param name="libName" />

		<xsl:variable name="helperClassName"
			select="concat($enum/@name, 'Helper')" />

		<!-- avoid code destruction through jalopy -->
		<!-- <xsl:text>&#10;//J-&#10;</xsl:text> -->

		<xsl:value-of select="$enum/@protection" />
		<xsl:text>&#32;enum&#32;</xsl:text>
		<xsl:value-of select="$enum/@name" />
		<xsl:text>&#32;implements&#32;INativeEnum&#32;&lt;&#32;</xsl:text>
		<xsl:value-of select="$enum/@name" />
		<xsl:text>&#32;&gt;&#32;{&#10;</xsl:text>

		<!-- do not generate content if type is on ignore list -->
		<xsl:if
			test="not($ignore_list/ignore_list/item[. = $enum/@fullName])">

			<xsl:for-each select="$enum/enum">
				<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
				<xsl:value-of select="@name" />
				<xsl:variable name="name" select="@name" />
				<xsl:text>(</xsl:text>

				<xsl:value-of select="$helperClassName" />
				<xsl:text>.</xsl:text>

				<xsl:text>ENUM_VALUES[</xsl:text>
				<xsl:value-of select="position() - 1" />
				<xsl:text>])</xsl:text>
				<xsl:if test="position()!=last()">
					<xsl:text>,&#10;</xsl:text>
				</xsl:if>
			</xsl:for-each>

			<xsl:text>;&#10;&#10;</xsl:text>
			<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
			<xsl:text>private int value;</xsl:text>
			<xsl:text>&#10;&#10;</xsl:text>
			<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
			<xsl:value-of select="$enum/@name" />
			<xsl:text>(int i) {&#10;</xsl:text>
			<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
			<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
			<xsl:text>this.value = i;&#10;</xsl:text>
			<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
			<xsl:text>}&#10;&#10;</xsl:text>

			<!-- get value -->
			<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
			<xsl:text>public&#32;int&#32;getValue()&#32;{&#10;</xsl:text>
			<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
			<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
			<xsl:text>return&#32;value;&#10;</xsl:text>
			<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
			<xsl:text>}&#10;&#10;</xsl:text>

			<!-- get enum -->
			<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
			<xsl:text>public&#32;</xsl:text>
			<xsl:value-of select="$enum/@name" />
			<xsl:text>&#32;getEnum(int&#32;val)&#32;{&#10;</xsl:text>
			<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
			<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
			<xsl:text>return&#32;toEnum(val);&#10;</xsl:text>
			<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
			<xsl:text>}&#10;&#10;</xsl:text>

			<!-- enum mapping, switch case -->
			<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
			<xsl:text>public&#32;static final&#32;</xsl:text>
			<xsl:value-of select="$enum/@name" />
			<xsl:text>&#32;toEnum(int&#32;retval)&#32;{&#10;</xsl:text>
			<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
			<xsl:text>if&#32;(retval&#32;==</xsl:text>
			<xsl:value-of select="$enum/enum[position()=1]/@name" />
			<xsl:text>.value)&#10;</xsl:text>
			<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
			<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
			<xsl:text>return&#32;</xsl:text>
			<xsl:value-of select="$enum/@name" />
			<xsl:text>.</xsl:text>
			<xsl:value-of select="$enum/enum[position()=1]/@name" />
			<xsl:text>;&#10;</xsl:text>

			<xsl:for-each select="$enum/enum">
				<xsl:if test="position()!=1">
					<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
					<xsl:text>else&#32;if&#32;(retval&#32;==</xsl:text>
					<xsl:value-of select="@name" />
					<xsl:text>.value)&#10;</xsl:text>
					<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
					<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
					<xsl:text>return&#32;</xsl:text>
					<xsl:value-of select="../@name" />
					<xsl:text>.</xsl:text>
					<xsl:value-of select="@name" />
					<xsl:text>;&#10;</xsl:text>
				</xsl:if>
			</xsl:for-each>

			<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
			<xsl:text>throw new RuntimeException("wrong number in jni call for an enum");&#10;</xsl:text>
			<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
			<xsl:text>}&#10;</xsl:text>
			<xsl:text>}&#10;</xsl:text>

			<!-- reenable jalopy code formatting -->
			<!-- <xsl:text>&#10;//J+&#10;</xsl:text> -->


			<!-- create helper class to get correct native values -->

			<!-- find out if we create an inner class -->
			<xsl:variable name="isInnerClass"
				select="../name() eq 'class' or ../name() eq 'struct'" />

			<xsl:text>&#10;</xsl:text>
			<xsl:if test="$isInnerClass">
				<xsl:text>static&#32;</xsl:text>
			</xsl:if>
			<xsl:text>class&#32;</xsl:text>
			<xsl:value-of select="$helperClassName" />
			<xsl:text>{&#10;</xsl:text>

			<!-- create static initializer -->
			<xsl:if test="not($isInnerClass)">
<!--			  <xsl:text>static {System.loadLibrary("</xsl:text>
			  <xsl:value-of select="if ($config/config/java/nativelib)
				then $config/config/java/nativelib
				else $libName" />
			  <xsl:text>");&#10;</xsl:text> -->
				<!-- <xsl:text>static { System.loadLibrary("jgapp"); }&#10;</xsl:text> -->
			</xsl:if>

			<!-- class content, an array containing the values and a native method to obtain them -->
			<xsl:text>
				public static final int[] ENUM_VALUES =
				getEnumValues();&#10;
			</xsl:text>
			<xsl:text>
				private static native int[] getEnumValues();&#10;
			</xsl:text>
			<xsl:text>&#10;</xsl:text>

		</xsl:if>

		<!-- generate comment for ignored -->
		<xsl:if
			test="$ignore_list/ignore_list/item[. = $enum/@fullName]">
			<xsl:text>// this type is ignored&#10;</xsl:text>
		</xsl:if>

		<!-- close class declaration  -->
		<xsl:text>};&#10;&#10;</xsl:text>

	</xsl:template>
</xsl:stylesheet>
