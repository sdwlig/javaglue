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
	xmlns:str="http://exslt.org/strings"
	xmlns:xbig="http://xbig.sourceforge.net/XBiG">

	<xsl:import href="javaAccessMethodDeclaration.xslt" />
	<xsl:import href="javaUtil.xslt" />
	<xsl:import href="../../exslt/str.split.template.xsl" />
	<xsl:import href="../../util/metaMethodName.xslt" />
	<xsl:import
		href="../../util/createFunctionsForPublicAttribute.xslt" />

	<xd:doc type="stylesheet">
		<xd:short>
			Generate an interface for a single original class or struct,
			to handle multiple inheritance
		</xd:short>
	</xd:doc>

	<xd:doc type="template">
		<xd:short>
			Generates a java interface. It does not look for inherited
			methods.
		</xd:short>
		<xd:param name="config">config file.</xd:param>
		<xd:param name="class">
			class or struct to be processed.
		</xd:param>
		<xd:param name="buildFile">
			ant build.xml file. Needed for called templates.
		</xd:param>
		<xd:param name="libName">
			Library name. Needed for called templates.
		</xd:param>
		<xd:param name="isOuterClassTemplate">
			Boolean value that indicates if this is an inner type of a template.
			Usually false() except for some inner types.
		</xd:param>
	</xd:doc>
	<xsl:template name="javaInterface">
		<xsl:param name="config" />
		<xsl:param name="class" />
		<xsl:param name="buildFile" />
		<xsl:param name="libName" />
		<xsl:param name="isOuterClassTemplate" as="xs:boolean"/>

		<xsl:message>Generating Java interface for class <xsl:value-of select="$class/@fullName"/></xsl:message>

		<!-- shortcut for class name -->
		<xsl:variable name="class_name" select="$class/@name" />

		<!-- find out if we create an inner class -->
		<xsl:variable name="isInnerClass"
			select="../name() eq 'class' or ../name() eq 'struct'" />

		<!-- create interface name -->
		<xsl:variable name="interfaceName">
			<xsl:value-of select="$config/config/java/interface/prefix" />
			<xsl:value-of select="$class/@name" />
			<xsl:value-of select="$config/config/java/interface/suffix" />
		</xsl:variable>

		<!-- write class declaration -->
		<!-- 
		<xsl:choose>
			<xsl:when test="$class/@protection ne ''">
				<xsl:value-of select="$class/@protection" />
			</xsl:when>
			<xsl:otherwise> -->
				<xsl:text>public</xsl:text><!-- 
			</xsl:otherwise>
		</xsl:choose> -->
		<xsl:text>&#32;</xsl:text>
		<xsl:if test="$isInnerClass">
			<xsl:text>static&#32;</xsl:text>
		</xsl:if>
		<xsl:text>interface&#32;</xsl:text>
		<xsl:value-of select="$interfaceName" />

		<!-- if this class is a template -->
		<xsl:if test="$class/@template  and
					not($ignore_list/ignore_list/item[. = $class/@fullName])">
			<xsl:text>&#32;&lt;&#32;</xsl:text>

			<!-- OGRE 1.6 custom mem alloc problem
			     we could generate something like class Foo < T extends Bar > here.
			     Bar would be @templateType.
			<xsl:for-each
				select="$class/templateparameters/templateparameter
								[@templateType = 'class' or @templateType = 'typename']">
			-->
			<xsl:for-each
				select="$class/templateparameters/templateparameter">
				<xsl:value-of select="@templateDeclaration" />

				<!-- outcommented for primitive types as template parameters -->
				<!-- <xsl:text>&#32;extends&#32;INativeObject</xsl:text> -->

				<xsl:if test="position() != last()">
					<xsl:text>,&#32;</xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:text>&#32;&gt;</xsl:text>
		</xsl:if>

		<!-- all generated interfaces must be INativeObjects -->
		<xsl:text>&#32;extends&#32;</xsl:text>
		<xsl:text>INativeObject</xsl:text>

		<!-- extended interfaces -->
		<xsl:if test="inherits/baseClass">
			<xsl:text>,&#32;</xsl:text>
			<xsl:for-each select="inherits/baseClass">

				<!-- find and print java name of baseclass -->
				<!-- TODO check what happens if there is a typedef for a template
						  which inherits something -->

				<xsl:choose>
					<!-- this class is a typedef for a template -->
					<xsl:when test="./@originalTypedefBasetype">
						<xsl:choose>

							<!-- generate no type parameters if type is on ignore_list -->
							<xsl:when test="not($ignore_list/ignore_list/item[. = $class/@fullName])">
								<xsl:variable name="generatedParam">
									<xsl:element name="param">
										<xsl:attribute name="passedBy" select="'value'" />
										<xsl:element name="type">
											<xsl:value-of select="./@originalTypedefBasetype" />
										</xsl:element>
									</xsl:element>
								</xsl:variable>

								<xsl:call-template name="javaType">
									<xsl:with-param name="config" select="$config"/>
									<xsl:with-param name="param" select="$generatedParam"/>
									<xsl:with-param name="class" select="$class"/>
									<xsl:with-param name="typeName" 
											select="./@originalTypedefBasetype"/>
									<xsl:with-param name="writingNativeMethod" select="false()" />
									<xsl:with-param name="isTypeParameter" select="false()" />
								</xsl:call-template>
							</xsl:when>

							<!-- this type is on ignore list -->
							<xsl:otherwise>
								<xsl:value-of select="xbig:getFullJavaName(
											./@fullBaseClassName, $class, $root, $config)" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>

					<!-- class inherits a template -->
					<xsl:when test="contains(./@fullBaseClassName, '&lt;')">
						<xsl:variable name="generatedParam">
							<xsl:element name="param">
								<xsl:attribute name="passedBy" select="'value'" />
								<xsl:element name="type">
									<xsl:value-of select="./@originalTypedefBasetype" />
								</xsl:element>
							</xsl:element>
						</xsl:variable>
						<xsl:call-template name="javaType">
							<xsl:with-param name="config" select="$config"/>
							<xsl:with-param name="param" select="$generatedParam"/>
							<xsl:with-param name="class" select="$class"/>
							<xsl:with-param name="typeName" 
									select="./@fullBaseClassName"/>
							<xsl:with-param name="writingNativeMethod" select="false()" />
							<xsl:with-param name="isTypeParameter" select="false()" />
						</xsl:call-template>
					</xsl:when>

					<!-- inheritance without templates -->
					<xsl:otherwise>
						<xsl:value-of select="xbig:getFullJavaName(
											xbig:resolveTypedef(./@fullBaseClassName, $class, $root), $class, $root, $config)" />
					</xsl:otherwise>
				</xsl:choose>

				<!-- gen commas as seperator between base interfaces -->
				<xsl:if test="position()!=last()">
					<xsl:text>,&#32;</xsl:text>
				</xsl:if>

			</xsl:for-each>
		</xsl:if>

		<!-- start interface content -->
		<xsl:text>&#32;{&#10;&#10;</xsl:text>

		<!-- do not generate content if type is on ignore list -->
		<xsl:if
			test="not($ignore_list/ignore_list/item[. = $class/@fullName])">

			<!-- handle inner classes & structs -->
			<xsl:for-each select="class">
				<xsl:call-template name="javaInterface">
					<xsl:with-param name="config" select="$config" />
					<xsl:with-param name="class" select="." />
					<xsl:with-param name="buildFile" select="$buildFile" />
					<xsl:with-param name="libName" select="$libName" />
					<xsl:with-param name="isOuterClassTemplate">
						<xsl:choose>
							<xsl:when test="$isOuterClassTemplate = true() or $class/@template">
								<xsl:sequence select="true()"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:sequence select="false()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
			<xsl:for-each select="struct">
				<xsl:call-template name="javaInterface">
					<xsl:with-param name="config" select="$config" />
					<xsl:with-param name="class" select="." />
					<xsl:with-param name="buildFile"
						select="$buildFile" />
					<xsl:with-param name="isOuterClassTemplate">
						<xsl:choose>
							<xsl:when test="$isOuterClassTemplate = true() or $class/@template">
								<xsl:sequence select="true()"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:sequence select="false()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
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
						<xsl:call-template name="javaInterface">
							<xsl:with-param name="config"
								select="$config" />
							<xsl:with-param name="class" select="." />
							<xsl:with-param name="buildFile" select="$buildFile" />
							<xsl:with-param name="libName" select="$libName" />
							<xsl:with-param name="isOuterClassTemplate">
								<xsl:choose>
									<xsl:when test="$isOuterClassTemplate = true() or $class/@template">
										<xsl:sequence select="true()"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:sequence select="false()"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:if>
			</xsl:for-each>

			<xsl:variable name="methodsForJava">
				<xsl:call-template name="getValidMethodList">
					<xsl:with-param name="functionNodeList" select="." />
				</xsl:call-template>
			</xsl:variable>

			<!-- As there are problems with interfaces for templates, they don't get any methods -->
			<xsl:if test="not($class/@template) and not($isOuterClassTemplate = true())">

				<!-- handling of member functions -->
				<xsl:for-each select="$methodsForJava/function">
					<xsl:variable name="currentMethod" select="." />
					<xsl:variable name="currentMethodPos"
						select="position()" />

					<!-- change method name if const overloading is used -->
					<xsl:variable name="methodContainer">
						<xsl:choose>
							<xsl:when
								test="(count(../function[name = $currentMethod/name]) > 1)">
								<!-- check for each method with the same name if it is equal -->
								<xsl:variable name="equalSiblings">
									<xsl:for-each
										select="../function[name = $currentMethod/name]">
										<!-- here I use the trick with count() and the union operator (|) to test a node's identity -->
										<xsl:if
											test="count(. | $currentMethod) != 1">
											<xsl:element name="check">
												<xsl:choose>
													<xsl:when
														test="xbig:areTheseMethodsEqualExceptConst($currentMethod, .,false())">
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

								<!-- check constness of methods with same name -->
								<xsl:choose>
									<xsl:when
										test="$equalSiblings/* = true()">
										<xsl:choose>
											<!-- change the name of the const version -->
											<xsl:when
												test="./@const = 'true'">
												<xsl:call-template
													name="createElementForConstOverloadedMethod">
													<xsl:with-param
														name="config" select="$config" />
													<xsl:with-param
														name="method" select="." />
												</xsl:call-template>
											</xsl:when>

											<!-- copy the not const version -->
											<xsl:otherwise>
												<xsl:copy-of select="." />
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>

									<!-- other method with same name but other parameters -->
									<xsl:otherwise>
										<!-- check if several c++ methods will be mapped into a same java method -->
										<xsl:variable
											name="equalInJava">
											<xsl:for-each
												select="$methodsForJava/function">
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
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>

							<!-- no const overloading for this method -->
							<xsl:otherwise>
								<xsl:copy-of select="." />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<!-- interfaces cannot have consructors or static methods -->
					<xsl:if
						test="name!=$class/@name and @static!='true'">

						<!-- check for configured operators -->
						<xsl:if test="not(starts-with(name, 'operator')) or 
									$config/config/java/operators/op = 
									normalize-space(substring-after(name, 'operator'))">
							<xsl:call-template
								name="javaAccessMethodDeclaration">
								<xsl:with-param name="config"
									select="$config" />
								<xsl:with-param name="class"
									select="$class" />
								<xsl:with-param name="method"
									select="$methodContainer/function" />
							</xsl:call-template>
	
							<!-- finish declaration -->
							<xsl:text>;&#10;&#10;</xsl:text>
						</xsl:if>
					</xsl:if>
				</xsl:for-each>

				<!-- handling of public attributes -->
				<xsl:for-each select="variable">
					<xsl:if test="@static != 'true'">
						<xsl:variable
							name="publicAttributeGettersAndSetters">
							<xsl:call-template
								name="createFunctionsForPublicAttribute">
								<xsl:with-param name="variable"
									select="." />
							</xsl:call-template>
						</xsl:variable>

						<xsl:for-each
							select="$publicAttributeGettersAndSetters/function">
							<xsl:call-template
								name="javaAccessMethodDeclaration">
								<xsl:with-param name="config"
									select="$config" />
								<xsl:with-param name="class"
									select="$class" />
								<xsl:with-param name="method"
									select="." />
							</xsl:call-template>

							<!-- finish declaration -->
							<xsl:text>;&#10;&#10;</xsl:text>
						</xsl:for-each>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>

			<!-- generate comment for templates -->
			<xsl:if test="$class/@template or $isOuterClassTemplate = true()">
				<xsl:text>
					// interfaces for templates do not get any methods&#10;
				</xsl:text>
			</xsl:if>
		</xsl:if>

		<!-- generate comment for ignored -->
		<xsl:if
			test="$ignore_list/ignore_list/item[. = $class/@fullName]">
			<xsl:text>// this type is ignored&#10;</xsl:text>
		</xsl:if>

		<!-- close class declaration  -->
		<xsl:text>}&#10;</xsl:text>

	</xsl:template>

</xsl:stylesheet>
