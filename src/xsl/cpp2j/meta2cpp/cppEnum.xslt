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
	xmlns:xbig="http://xbig.sourceforge.net/XBiG">

	<xsl:import href="../../util/path.xslt" />

	<xd:doc type="stylesheet">
		<xd:short>
			Generation of files for enum helper classes.
		</xd:short>
	</xd:doc>

	<xd:doc type="template">
		<xd:short>
			Creates header and source file for a java enum helper class.
		</xd:short>
		<xd:param name="enum">
			meta enumeration to be processed.
		</xd:param>
		<xd:param name="ns_prefix">
			prefix for class name. Contains java package.
		</xd:param>
		<xd:param name="include_dir">
			Directory for include files.
		</xd:param>
		<xd:param name="lib_dir">Directory for source files.</xd:param>
		<xd:param name="config">config file.</xd:param>
	</xd:doc>
	<xsl:template name="cppEnum">
		<xsl:param name="enum" />
		<xsl:param name="ns_prefix" />
		<xsl:param name="include_dir" />
		<xsl:param name="lib_dir" />
		<xsl:param name="config" />

		<!-- do not generate content if type is on ignore list -->
		<xsl:if
			test="not($ignore_list/ignore_list/item[. = $enum/@fullName])">

			<!-- find out if we create an inner class -->
			<xsl:variable name="isInnerClass"
				select="../name() eq 'class' or ../name() eq 'struct'" />

			<!-- compose filename of current class without suffix -->
			<!-- the 00024 is for the $ of inner classes -->
			<xsl:variable name="class_prefix">
				<xsl:choose>
					<xsl:when test="$isInnerClass">
						<xsl:value-of
							select="concat($ns_prefix, '_', '00024', @name, 'Helper')" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of
							select="concat($ns_prefix, '_', @name, 'Helper')" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<!-- compose filename of current class without suffix -->
			<xsl:variable name="main_filename"
				select="concat('class_', $class_prefix)" />

			<!-- compose basic header filename of current class -->
			<xsl:variable name="basic_header_filename"
				select="concat($main_filename,'.h')" />

			<!-- compose full header filename of current class -->
			<xsl:variable name="header_filename"
				select="concat($include_dir, '/', $basic_header_filename)" />

			<!-- compose implementation filename of current class -->
			<xsl:variable name="impl_filename"
				select="concat($lib_dir, '/', $main_filename,'.cpp')" />


			<!-- open header file -->
			<xsl:result-document
				href="{xbig:toFileURL($header_filename)}" format="textOutput">

				<!-- write file header with copyright information -->
				<xsl:call-template name="cppFileHeader">
					<xsl:with-param name="config" select="$config" />
				</xsl:call-template>

				<!-- generate macro name for preventing multiple inclusion -->
				<xsl:variable name="header_macro"
					select="concat( '__Included_', $class_prefix , '__')" />

				<!-- write standard C++ header macros for preventing multiple inclusion -->
				<xsl:text>&#10;#ifndef&#32;</xsl:text>
				<xsl:value-of select="$header_macro" />
				<xsl:text>&#10;</xsl:text>

				<xsl:text>#define&#32;</xsl:text>
				<xsl:value-of select="$header_macro" />
				<xsl:text>&#10;&#10;</xsl:text>

				<!-- include basic JNI utility functions -->
				<xsl:text>&#10;#include "jni_base.h"</xsl:text>

				<!-- open C environment for C++ compiler -->
				<xsl:text>&#10;&#10;#ifdef __cplusplus&#10;</xsl:text>
				<xsl:text>extern "C" {</xsl:text>
				<xsl:text>
					&#10;#endif /* __cplusplus */&#10;&#10;
				</xsl:text>

				<!-- comment for enum getter function -->
				<xsl:text>/*&#10;</xsl:text>
				<xsl:text>* Class:</xsl:text>
				<xsl:value-of select="$class_prefix" />
				<xsl:text>&#10;</xsl:text>
				<xsl:text>* Method:</xsl:text>
				<xsl:text>getEnumValues&#10;</xsl:text>
				<xsl:text>* Signature:</xsl:text>
				<xsl:text>()[I&#10;</xsl:text>
				<xsl:text>*/&#10;</xsl:text>

				<!-- declaration for enum getter function -->
				<xsl:text>JNIEXPORT jintArray JNICALL Java_</xsl:text>
				<xsl:value-of select="$class_prefix" />
				<xsl:text>_getEnumValues&#10;</xsl:text>
				<xsl:text>(JNIEnv *, jclass);&#10;</xsl:text>

				<!-- close C environment for C++ compiler -->
				<xsl:text>&#10;&#10;#ifdef __cplusplus</xsl:text>
				<xsl:text>&#10;} /* extern "C" */</xsl:text>
				<xsl:text>&#10;#endif /* __cplusplus */</xsl:text>

				<!-- close condition for preventing multiple inclusion -->
				<xsl:text>&#10;&#10;#endif /*</xsl:text>
				<xsl:value-of select="$header_macro" />
				<xsl:text>*/&#10;</xsl:text>

			</xsl:result-document>


			<!-- open implementation file -->
			<xsl:result-document href="{xbig:toFileURL($impl_filename)}"
				format="textOutput">

				<!-- write file header with copyright information -->
				<xsl:call-template name="cppFileHeader">
					<xsl:with-param name="config" select="$config" />
				</xsl:call-template>
				<xsl:text>&#10;&#10;</xsl:text>

				<!-- include all JNI utility functions -->
				<xsl:text>// use base library for cpp2j</xsl:text>
				<xsl:text>&#10;#include "jni_base_all.h"&#10;</xsl:text>

				<!-- include headers from config -->
				<xsl:if test="$config/config/cpp/always_include/header">
				<xsl:text>&#10;</xsl:text>
				<xsl:text>// includes from config</xsl:text>
				<xsl:text>&#10;</xsl:text>
					<xsl:for-each select="$config/config/cpp/always_include/header">
						<xsl:text>#include &lt;</xsl:text>
						<xsl:sequence select="." />
						<xsl:text>&gt;&#10;</xsl:text>
					</xsl:for-each>
				</xsl:if>

				<!-- include current header file if available -->
				<xsl:text>&#10;</xsl:text>
				<xsl:text>// import declaration of all functions</xsl:text>
				<xsl:text>&#10;#include "</xsl:text>
				<xsl:value-of select="$basic_header_filename" />
				<xsl:text>"&#10;</xsl:text>

				<!-- include header files from original library -->
				<xsl:text>&#10;</xsl:text>
				<xsl:text>// import header files of original library</xsl:text>
				<!-- 
				<xsl:variable name="nodeContainingIncludeFiles">
					<xsl:element name="node">
						<xsl:call-template name="findIncludeFiles">
							<xsl:with-param name="enum" select="$enum" />
						</xsl:call-template>
					</xsl:element>
				</xsl:variable>
				<xsl:for-each
					select="$nodeContainingIncludeFiles/node/*/libraryfile">
					<xsl:text>&#10;#include "</xsl:text>
					<xsl:value-of select="text()" />
					<xsl:text>"&#10;</xsl:text>
				</xsl:for-each>
				<xsl:text>&#10;&#10;</xsl:text>
				 -->
				<xsl:text>&#10;#include </xsl:text>
				<xsl:value-of select="if($enum/includes/@local = yes) then '&quot;' else '&lt;'" />
				<xsl:value-of select="$enum/includes" />
				<xsl:value-of select="if($enum/includes/@local = yes) then '&quot;' else '&gt;'" />
				<xsl:text>&#10;&#10;</xsl:text>

				<!-- comment for enum getter function -->
				<xsl:text>/*&#10;</xsl:text>
				<xsl:text>&#32;* Class:</xsl:text>
				<xsl:value-of select="$class_prefix" />
				<xsl:text>&#10;</xsl:text>
				<xsl:text>&#32;* Method:</xsl:text>
				<xsl:text>getEnumValues&#10;</xsl:text>
				<xsl:text>&#32;* Signature:</xsl:text>
				<xsl:text>()[I&#10;</xsl:text>
				<xsl:text>&#32;*/&#10;</xsl:text>

				<!-- declaration for enum getter function -->
				<xsl:text>JNIEXPORT jintArray JNICALL Java_</xsl:text>
				<xsl:value-of select="$class_prefix" />
				<xsl:text>_getEnumValues&#10;</xsl:text>
				<xsl:text>(JNIEnv * env, jclass that)&#10;</xsl:text>

				<!-- implementation for enum getter function -->
				<xsl:text>{&#10;</xsl:text>
				<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
				<xsl:text>jint enum_values[] = {&#10;</xsl:text>

				<!-- put all enum values into one array -->
				<xsl:for-each select="$enum/enum">
					<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
					<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
					<xsl:if test="../../name() != 'meta'">
						<xsl:value-of select="../../@fullName" />
						<xsl:text>::</xsl:text>
					</xsl:if>
					<xsl:value-of select="@name" />
					<xsl:if test="position()!=last()">
						<xsl:text>,&#10;</xsl:text>
					</xsl:if>
					<xsl:if test="position() eq last()">
						<xsl:variable name="numberOfEnums"
							select="position()" />

						<!-- close enum getter function -->
						<xsl:text>&#10;</xsl:text>
						<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
						<xsl:text>};&#10;</xsl:text>
						<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
						<xsl:text>jintArray array = env->NewIntArray(</xsl:text>
						<xsl:value-of select="$numberOfEnums" />
						<xsl:text>);&#10;</xsl:text>
						<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
						<xsl:text>env->SetIntArrayRegion(array, 0,</xsl:text>
						<xsl:value-of select="$numberOfEnums" />
						<xsl:text>, enum_values);&#10;</xsl:text>
						<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
						<xsl:text>return array;&#10;</xsl:text>
						<xsl:text>}&#10;</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:result-document>
		</xsl:if>
	</xsl:template>


	<xd:doc type="template">
		<xd:short>
			Helper template to find out which files must be included by
			an enum source file.
		</xd:short>
		<xd:param name="enum">
			meta enumeration to be processed.
		</xd:param>
	</xd:doc>
	<xsl:template name="findIncludeFiles">
		<xsl:param name="enum" />

		<xsl:choose>
			<xsl:when test="$enum/../libraryfile">
				<xsl:copy-of select="$enum/.." />
			</xsl:when>
			<xsl:when test="$enum = $root">
				<xsl:copy-of select="$root/meta" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="findIncludeFiles">
					<xsl:with-param name="enum" select="$enum/.." />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
