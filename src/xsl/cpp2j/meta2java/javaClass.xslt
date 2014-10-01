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

	<xsl:import href="javaNativeMethod.xslt" />
	<xsl:import href="javaAccessMethod.xslt" />
	<xsl:import href="javaEnum.xslt" />
	<xsl:import href="javaUtil.xslt" />
	<xsl:import href="../../util/metaInheritedMethods.xslt" />
	<xsl:import href="../../util/createClassFromTemplateTypedef.xslt" />
	<xsl:import
		href="../../util/createFunctionsForPublicAttribute.xslt" />

	<xd:doc type="stylesheet">
		<xd:short>
			Generate mapping of a single original class or struct
		</xd:short>
	</xd:doc>

	<xd:doc type="template">
		<xd:short>
			Generates a java class. Can be called for classes or
			structs. Handles inner types as well as methods and
			attributes.
		</xd:short>
		<xd:param name="config">config file.</xd:param>
		<xd:param name="class">
			class or struct to be generated.
		</xd:param>
		<xd:param name="buildFile">
			ant build.xml file. Needed for project name in static
			initializer.  Unused now.
		</xd:param>
		<xd:param name="libName">
			libName Needed for project name in static
			initializer.
		</xd:param>
	</xd:doc>
	<xsl:template name="javaClass">
		<xsl:param name="config" />
		<xsl:param name="class" />
		<xsl:param name="buildFile" />
		<xsl:param name="libName" />

		<xsl:message>Generating Java code for class <xsl:value-of select="$class/@fullName"/></xsl:message>

		<!-- 
		<xsl:variable name="isAbstract"
			select="xbig:areThereUnimplementedAbstractMethods($class)" />		
		 -->
		<xsl:variable name="isAbstract"
			select="$class/@abstract = 'true'" />

		<!-- shortcut for class configuration -->
		<xsl:variable name="class_config"
			select="$config/config/java/class" />

		<!-- shortcut for class name -->
		<xsl:variable name="class_name" select="$class/@name" />

		<!-- find out if we create an inner class -->
		<xsl:variable name="isInnerClass"
			select="../name() eq 'class' or ../name() eq 'struct' or
												  $class/@isInnerClass = 'true'" />

		<!-- write class declaration -->
		<xsl:choose>
			<xsl:when test="$class/@protection ne ''">
				<xsl:value-of select="$class/@protection" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>public</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>&#32;</xsl:text>

		<xsl:if test="$isInnerClass">
			<xsl:text>static&#32;</xsl:text>
		</xsl:if>
		<xsl:text>class&#32;</xsl:text>
		<xsl:value-of select="$class_name" />

		<!-- configured inheritance -->
		<xsl:if test="$class_config/inherits">
			<xsl:text>&#32;extends&#32;</xsl:text>
			<xsl:value-of select="$class_config/inherits" />
		</xsl:if>

		<!-- implement interface -->
		<xsl:text>&#32;implements&#32;</xsl:text>
		<!-- 
			<xsl:value-of select="$config/config/java/interface/prefix" />
			<xsl:value-of select="$class_name" />
			<xsl:value-of select="$config/config/java/interface/suffix" />
		-->
		<xsl:value-of
			select="xbig:getFullJavaName($class/@fullName, $class, $root, $config)" />

		<!-- start class content -->
		<xsl:text>&#32;{&#10;</xsl:text>

		<!-- create static initializer -->
		<!-- <xsl:if test="not($isInnerClass)"> -->
<!--		<xsl:text>static {System.loadLibrary("</xsl:text>
		<xsl:value-of select="if ($config/config/java/nativelib)
				then $config/config/java/nativelib
				else $libName" />
		<xsl:text>");&#10;</xsl:text> -->

		<!-- <xsl:text>static { System.loadLibrary("jgapp"); }&#10;</xsl:text> -->
		<!-- </xsl:if> -->

		<!-- do not generate content if type is on ignore list -->
		<xsl:if
		    test="not($ignore_list/ignore_list/item[. = $class/@fullName])">


			<!-- handle inner classes & structs -->
			<!-- ignore inner templates, see bug 1723249 -->
			<xsl:for-each select="class[not(./@template)]">
				<xsl:call-template name="javaClass">
					<xsl:with-param name="config" select="$config" />
					<xsl:with-param name="class" select="." />
					<xsl:with-param name="buildFile"
						select="$buildFile" />
				</xsl:call-template>
			</xsl:for-each>
			<xsl:for-each select="struct[not(./@template)]">
				<xsl:call-template name="javaClass">
					<xsl:with-param name="config" select="$config" />
					<xsl:with-param name="class" select="." />
					<xsl:with-param name="buildFile"
						select="$buildFile" />
				</xsl:call-template>
			</xsl:for-each>

			<!-- create enums -->
			<xsl:for-each select="enumeration">
				<xsl:call-template name="javaEnum">
					<xsl:with-param name="enum" select="." />
					<xsl:with-param name="buildFile"
						select="$buildFile" />
				</xsl:call-template>
			</xsl:for-each>

			<!-- check if we have to generate a class for a typedef -->
			<xsl:for-each select="typedef">
				<xsl:if test="contains(./@basetype, '&lt;')">
					<xsl:variable name="templateBaseName"
						select="normalize-space(substring-before(./@basetype, '&lt;'))" />
					<xsl:variable name="fullTemplateBaseName"
						select="xbig:getFullTypeName($templateBaseName, ., $root)" />
					<xsl:variable name="templateNode"
						select="$root//*[@fullName = $fullTemplateBaseName]" />
					<xsl:variable name="generatedClass">
						<xsl:call-template
							name="createClassFromTemplateTypedef">
							<xsl:with-param name="template"
								select="$templateNode" />
							<xsl:with-param name="typedef" select="." />
							<xsl:with-param name="isInnerClass"
								select="true()" />
						</xsl:call-template>
					</xsl:variable>

					<!-- generate the class -->
					<xsl:for-each select="$generatedClass/*">
						<xsl:call-template name="javaClass">
							<xsl:with-param name="config"
								select="$config" />
							<xsl:with-param name="class" select="." />
							<xsl:with-param name="buildFile"
								select="$buildFile" />
						</xsl:call-template>
					</xsl:for-each>
				</xsl:if>
			</xsl:for-each>

		</xsl:if> <!-- ignore list -->


		<!-- if additional class content defined in configuration -->
		<xsl:if test="$class_config/content">
			<xsl:text>&#32;</xsl:text>
			<xsl:value-of
				select="replace($class_config/content,'#classname#', $class_name)" />
		</xsl:if>


		<!-- check if ignore list says not to generate any method -->
		<xsl:if
			test="not($ignore_list/ignore_list/item[. = $class/@fullName]/@withoutAnyMethods = 'true')">


			<!-- get methods, with inherited -->
			<xsl:variable name="inheritedMethods">
				<xsl:call-template
					name="findRelevantInheritedMethods">
					<xsl:with-param name="config" select="$config" />
					<xsl:with-param name="class" select="$class" />
				</xsl:call-template>
			</xsl:variable>

			<!-- remove function that are equal to java -->
			<xsl:variable name="inheritedMethodsForJava">
				<xsl:call-template name="getValidMethodList">
					<xsl:with-param name="functionNodeList"
						select="$inheritedMethods" />
				</xsl:call-template>
			</xsl:variable>

			<!-- generate method impl -->
			<xsl:for-each select="$inheritedMethodsForJava/function">
				<!-- test if abstract class and ctor -->
				<xsl:if
					test="$isAbstract = false() or xbig:isCtor($class,.) = false()">

					<xsl:variable name="currentMethod" select="." />
					<xsl:variable name="currentMethodPos"
						select="position()" />

					<!-- change method name if const overloading is used -->
					<xsl:variable name="methodContainer">
						<xsl:choose>
							<xsl:when
								test="(count(../function[name = $currentMethod/name]) > 1)">
								<!-- check if several c++ methods will be mapped into a same java method -->
								<xsl:variable name="equalInJava">
									<xsl:for-each
										select="$inheritedMethodsForJava/function">
										<!-- check if two c++ method will be mapped into a same java method -->
										<!--<xsl:message>==== DEBUG INFO ====</xsl:message>
											<xsl:message>==== 3. position()=<xsl:value-of select="position()"/> ====</xsl:message>
											<xsl:message>====    $currentMethodPos=<xsl:value-of select="$currentMethodPos"/> ====</xsl:message>
											<xsl:message>==== DEBUG INFO ====</xsl:message>-->
										<xsl:if
											test="../function[name = $currentMethod/name]">
											<xsl:if
												test="position() &lt; $currentMethodPos">
												<xsl:element
													name="check">
													<xsl:choose>
														<xsl:when
															test="xbig:areTheseMethodsEqualInJava($currentMethod, .,false())">
															<!--<xsl:message>==== DEBUG INFO ====</xsl:message>
																<xsl:message>==== 4. Functions are equal in Java ====</xsl:message>
																<xsl:message>==== DEBUG INFO ====</xsl:message>-->
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
										</xsl:if>
									</xsl:for-each>
								</xsl:variable>


								<xsl:choose>
									<xsl:when
										test="$equalInJava/* = true()">
										<xsl:call-template
											name="createElementForSameInJavaMethod">
											<xsl:with-param
												name="config" select="$config" />
											<xsl:with-param
												name="method" select="." />
										</xsl:call-template>
									</xsl:when>
									<xsl:otherwise>
										<xsl:copy-of select="." />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>

							<!-- no overloading for this method -->
							<xsl:otherwise>
								<xsl:copy-of select="." />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<xsl:call-template name="javaAccessMethod">
						<xsl:with-param name="config" select="$config" />
						<xsl:with-param name="class" select="$class" />
						<xsl:with-param name="method"
							select="$methodContainer/function" />
					</xsl:call-template>

					<xsl:text>&#10;&#10;</xsl:text>

					<xsl:call-template name="javaNativeMethod">
						<xsl:with-param name="config" select="$config" />
						<xsl:with-param name="class" select="$class" />
						<xsl:with-param name="method" select="." />
					</xsl:call-template>
					<xsl:text>&#10;&#10;</xsl:text>
				</xsl:if>
			</xsl:for-each>

			<!-- generate public attributes getters and setters -->
			<xsl:for-each
				select="$inheritedMethods/attribute/variable">
				<xsl:variable name="publicAttributeGettersAndSetters">
					<xsl:call-template
						name="createFunctionsForPublicAttribute">
						<xsl:with-param name="variable" select="." />
					</xsl:call-template>
				</xsl:variable>

				<xsl:for-each
					select="$publicAttributeGettersAndSetters/function">
					<xsl:call-template name="javaAccessMethod">
						<xsl:with-param name="config" select="$config" />
						<xsl:with-param name="class" select="$class" />
						<xsl:with-param name="method" select="." />
					</xsl:call-template>

					<xsl:text>&#10;&#10;</xsl:text>

					<xsl:call-template name="javaNativeMethod">
						<xsl:with-param name="config" select="$config" />
						<xsl:with-param name="class" select="$class" />
						<xsl:with-param name="method" select="." />
					</xsl:call-template>

					<xsl:text>&#10;&#10;</xsl:text>
				</xsl:for-each>
			</xsl:for-each>

		</xsl:if> <!-- ignore list without methods -->

		<!-- close class declaration  -->
		<xsl:text>}&#10;</xsl:text>

	</xsl:template>


</xsl:stylesheet>
