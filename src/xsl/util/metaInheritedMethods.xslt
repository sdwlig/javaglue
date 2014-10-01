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

	<xsl:import href="metaMethodsEqual.xslt" />
	<xsl:import href="metaMethodName.xslt" />
	<xsl:import href="createClassFromTemplateTypedef.xslt" /><!-- needed if base class is a template -->

	<xd:doc type="stylesheet">
		<xd:short>
			this file contains some helper templates and functions to
			deal with inheritance.
		</xd:short>
	</xd:doc>

	<xd:doc type="template">
		<xd:short>
			Find the inherited methods and attributes that must be implemented by java
			classes. This template shall be called by javaClass. It calls other templates in this
			stylesheet and handles method that are overloaded using 'const' (void a() vs void a() const).
			It does not handle const parameters.
		</xd:short>
		<xd:param name="config">config file.</xd:param>
		<xd:param name="class">class or struct which shall be expanded with it's inherited methods.</xd:param>
	</xd:doc>
	<!-- this template hadles const overloading -->
	<xsl:template name="findRelevantInheritedMethods">
		<xsl:param name="config" />
		<xsl:param name="class" />

		<!-- get the method list -->
		<xsl:variable name="methodList">
			<xsl:call-template
				name="findRelevantInheritedMethodsWithoutTakingCareAboutConstOverloading">
				<xsl:with-param name="config" select="$config" />
				<xsl:with-param name="class" select="$class" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:for-each select="$methodList/function">
			<xsl:variable name="currentMethod" select="." />
			<xsl:variable name="currentMethodPos" select="position()" />
			<xsl:choose>
				<xsl:when
					test="count(../function[name = $currentMethod/name]) > 1">
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
						<xsl:when test="$equalSiblings/* = true()">
							<xsl:choose>
								<!-- change the name of the const version -->
								<xsl:when test="./@const = 'true'">
									<xsl:call-template
										name="createElementForConstOverloadedMethod">
										<xsl:with-param name="config"
											select="$config" />
										<xsl:with-param name="method"
											select="." />
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
							<xsl:copy-of select="." />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>

				<!-- no const overloading for this method -->
				<xsl:otherwise>
					<xsl:copy-of select="." />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>

		<!-- just copy public attributes -->
		<xsl:for-each select="$methodList/attribute">
			<xsl:copy-of select="." />
		</xsl:for-each>

	</xsl:template>


	<xd:doc type="template">
		<xd:short>
			Find the inherited methods and filter c-tors and overloaded
			methods. For internal usage. Does main filter work.
		</xd:short>
		<xd:param name="config">config file.</xd:param>
		<xd:param name="class">class or struct which shall be expanded with it's inherited methods.</xd:param>
	</xd:doc>
	<xsl:template
		name="findRelevantInheritedMethodsWithoutTakingCareAboutConstOverloading">
		<xsl:param name="config" />
		<xsl:param name="class" />

		<!-- find all inherited methods -->
		<xsl:variable name="allInheritedMethods">
			<xsl:call-template name="findAllInheritedMethods">
				<xsl:with-param name="config" select="$config" />
				<xsl:with-param name="class" select="$class" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="allInheritedMethodsWithoutConstParams">
			<xsl:for-each select="$allInheritedMethods/function">
				<xsl:choose>
					<!-- change if function has const parameters passed by value -->
					<xsl:when
						test="count(current()/parameters/parameter[./type/@const = 'true']) > 0">
						<xsl:call-template
							name="copyFunctionAndRemoveConstFromByValuePassedParams">
							<xsl:with-param name="functionNode"
								select="current()" />
						</xsl:call-template>
					</xsl:when>
					<!-- function has no const parameters passed by value -->
					<xsl:otherwise>
						<xsl:copy-of select="." />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>		

		<!-- filter -->
		<xsl:for-each
			select="$allInheritedMethodsWithoutConstParams/function">
			<xsl:variable name="currentMethod" select="." />
			<xsl:variable name="currentMethodPos" select="position()" />

			<xsl:choose>

				<!-- filter base class c-tors -->
				<xsl:when test="not(./type) and ./name != $class/@name">
				</xsl:when>

				<!-- filter c-tors of current class that have unresolved types as parameters -->
				<xsl:when
					test="./name = $class/@name and ./parameters">

					<xsl:variable name="unresolvedTypes">
						<xsl:for-each select="./parameters/parameter">
							<xsl:variable name="typeName">
								<xsl:choose>
									<xsl:when
										test="starts-with(./type, '::')">
										<xsl:value-of
											select="substring-after(./type, '::')" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="./type" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>

							<xsl:element name="unresolved">

								<xsl:variable name="fullTypeName"
									select="xbig:resolveTypedef($typeName, $class, $root)" />

								<xsl:choose>
									<!-- primitive types -->
									<xsl:when
										test="$config/config/java/types/type[@meta = $fullTypeName]">
										<xsl:sequence select="false()" />
									</xsl:when>
									<xsl:when
										test="$root//*[@fullName eq $fullTypeName]/@protection ne 'public'">
										<xsl:sequence select="true()" />
									</xsl:when>
									<xsl:when
										test="xbig:isEnum($fullTypeName, $class, $root)">
										<xsl:sequence select="false()" />
									</xsl:when>
									<xsl:when
										test="xbig:isTypedef($fullTypeName, $class, $root)">
										<xsl:sequence select="false()" />
									</xsl:when>
									<xsl:when
										test="xbig:isClassOrStruct($fullTypeName, $class, $root)">
										<!-- if parameter is a template without type parameters
											 , filter it! See bug 1728990, t53 and Ogre::SharedPtr -->
										<xsl:sequence select="if (
											$root//class[@fullName = $fullTypeName]/@template = 'true' or
											$root//struct[@fullName = $fullTypeName]/@template = 'true')
											then true() else false()" />
									</xsl:when>
									<xsl:when
										test="xbig:isTemplateTypedef($fullTypeName, $class, $root)">
										<xsl:sequence select="false()" />
									</xsl:when>

									<!-- template parameters -->
									<xsl:when
										test="$class/templateparameters/templateparameter
																	[@templateDeclaration = $typeName]">
										<!-- TODO check if $fullTypeName must be used here -->
										<xsl:sequence select="false()" />
									</xsl:when>

									<!-- filter -->
									<xsl:otherwise>
										<xsl:sequence select="true()" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:element>
						</xsl:for-each>
					</xsl:variable>

					<!-- filter c-tor if there is at least one unresolved parameter -->
					<xsl:choose>
						<xsl:when test="$unresolvedTypes/* = true()">
						</xsl:when>
						<xsl:otherwise>
							<xsl:copy-of select="." />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>

				<!-- filter operators -->
				<xsl:when test="starts-with(name, 'operator')">
					<!-- keep operators that are configured -->
					<xsl:if test="$config/config/java/operators/op = 
									normalize-space(substring-after(name, 'operator'))">
						<xsl:copy-of select="." />
					</xsl:if>
				</xsl:when>

				<!-- filter duplicate methods -->
				<xsl:when
					test="count(../function[name = $currentMethod/name]) > 1">
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
											test="xbig:areTheseMethodsEqual($currentMethod, .,false())">

											<!-- remember outer loop position of equal methods -->
											<xsl:variable name="currentMethodOfInnerLoop" select="." />
											<xsl:for-each select="../function">
												<xsl:if test="count($currentMethodOfInnerLoop | .) = 1">
													<xsl:attribute name="pos" select="position()"/>
												</xsl:if>
											</xsl:for-each>

											<!-- remember that methods are equal -->
											<xsl:value-of
												select="true()" />
										</xsl:when>
										<xsl:otherwise>
											<!-- remember that methods are different -->
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
							<!-- we must take the first one, to use the correct class name in JNI for multiple inheritance
								 handling of multiple inheritance has changed to support abstract classes as return types -->
							<xsl:if
								test="$equalSiblings/*[@pos][1]/@pos >= $currentMethodPos">
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

		<!-- filter duplicate attributes -->
		<xsl:for-each select="$allInheritedMethods/attribute">
			<xsl:choose>

				<xsl:when test="following-sibling = ."></xsl:when>

				<xsl:otherwise>
					<xsl:copy-of select="." />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>

	</xsl:template>


	<xd:doc type="template">
		<xd:short>
			Find all inherited methods, including base class c-tors and
			overridden methods. For internal usage. Is recursive.
		</xd:short>
		<xd:param name="config">Config file.</xd:param>
		<xd:param name="class">
			Class or struct which shall be expanded with it's inherited methods.
		</xd:param>
		<xd:param name="baseClassTypedef">
			Optional parameter. Needed if base class is a template.
		</xd:param>
	</xd:doc>
	<xsl:template name="findAllInheritedMethods">
		<xsl:param name="config" />
		<xsl:param name="class" />
		<xsl:param name="baseClassTypedef" />

		<!-- if we derive a template -->
		<xsl:variable name="resolvedTypeParas">
			<xsl:choose>
				<!-- build list of type parameters -->
				<xsl:when test="$baseClassTypedef">
					<xsl:call-template
						name="buildListOfTypeParameters">
						<xsl:with-param name="template" select="$class" />
						<xsl:with-param name="typedef"
							select="$baseClassTypedef" />
					</xsl:call-template>
				</xsl:when>

				<!-- do nothing -->
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- return methods -->
		<xsl:for-each select="$class/function">
			<xsl:choose>
				<!-- change template types, but not for c-tors -->
				<xsl:when test="$baseClassTypedef and type">
					<xsl:call-template name="createFunctionElement">
						<xsl:with-param name="function" select="." />
						<xsl:with-param name="typedef"
							select="$baseClassTypedef" />
						<xsl:with-param name="template" select="$class" />
						<xsl:with-param name="resolvedTypeParas"
							select="$resolvedTypeParas" />
					</xsl:call-template>
				</xsl:when>

				<!-- no template, nothing to change -->
				<xsl:otherwise>
					<xsl:copy-of select="." />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>

		<!-- inherited public attributes -->
		<xsl:for-each select="$class/variable">
			<xsl:element name="attribute">
				<xsl:choose>
					<!-- change template types -->
					<xsl:when test="$baseClassTypedef">
						<xsl:call-template
							name="createVariableElement">
							<xsl:with-param name="variable" select="." />
							<xsl:with-param name="typedef"
								select="$baseClassTypedef" />
							<xsl:with-param name="template"
								select="$class" />
							<xsl:with-param name="resolvedTypeParas"
								select="$resolvedTypeParas" />
						</xsl:call-template>
					</xsl:when>

					<!-- no template, nothing to change -->
					<xsl:otherwise>
						<xsl:copy-of select="." />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:for-each>

		<!-- recurse over inheritance tree -->
		<xsl:if test="$class/inherits">
			<xsl:for-each select="$class/inherits/baseClass">

				<!-- find out if base class is a template -->
				<xsl:variable name="baseClassIsTemplate">
					<xsl:choose>
						<xsl:when
							test="contains(@fullBaseClassName, '&lt;')">
							<xsl:value-of select="true()" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="false()" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<!-- get full name of base class -->
				<xsl:variable name="fullNameOfCurrentBaseClass">
					<xsl:choose>
						<xsl:when
							test="$baseClassIsTemplate = true()">
							<xsl:value-of
								select="normalize-space(
											substring-before(@fullBaseClassName, '&lt;'))" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@fullBaseClassName" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<!-- generate typedef to resolve type parameters used in inheritance (ogre4j, t13) -->
				<xsl:variable name="generatedTypedef">
					<xsl:choose>
						<xsl:when
							test="$baseClassIsTemplate = true()">
							<xsl:element name="typedef">
								<xsl:attribute name="name"
									select="$class/@name" />
								<xsl:attribute name="fullName"
									select="$class/@fullName" />
								<xsl:attribute name="protection"
									select="'public'" />
								<xsl:attribute name="basetype"
									select="@fullBaseClassName" />
							</xsl:element>
						</xsl:when>

						<!-- do nothing -->
						<xsl:otherwise></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<!-- recurse -->
				<xsl:call-template name="findAllInheritedMethods">
					<xsl:with-param name="config" select="$config" />
					<xsl:with-param name="class"
						select="root()//class
										[@fullName=$fullNameOfCurrentBaseClass]" />
					<xsl:with-param name="baseClassTypedef"
						select="$generatedTypedef/*" />
				</xsl:call-template>

				<xsl:call-template name="findAllInheritedMethods">
					<xsl:with-param name="config" select="$config" />
					<xsl:with-param name="class"
						select="root()//struct
									[@fullName=$fullNameOfCurrentBaseClass]" />
					<xsl:with-param name="baseClassTypedef"
						select="$generatedTypedef/*" />
				</xsl:call-template>

			</xsl:for-each>
		</xsl:if>

	</xsl:template>


	<xd:doc type="function">
		<xd:short>
			Returns true if a class contains at least one inherited and
			unimplemented abstract method.
		</xd:short>
		<xd:param name="class">class or struct which shall be checked.</xd:param>
	</xd:doc>
	<xsl:function name="xbig:areThereUnimplementedAbstractMethods" as="xs:boolean">
		<xsl:param name="class" />

		<!-- find all inherited methods -->
		<xsl:variable name="allInheritedMethods">
			<xsl:call-template name="findAllInheritedMethods">
				<xsl:with-param name="config" select="$config" />
				<xsl:with-param name="class" select="$class" />
			</xsl:call-template>
		</xsl:variable>

		<!-- check for each method if it is abstract and implemented -->
		<xsl:variable name="allCheckResults">
			<xsl:for-each select="$allInheritedMethods/function">
				<xsl:element name="check">
					<xsl:choose>

						<!-- check for implementations of abstract methods -->
						<xsl:when test="@virt='pure-virtual'">
							<xsl:variable name="currentMethod"
								select="." />
							<xsl:choose>

								<!-- check if there are methods with the same name -->
								<xsl:when
									test="count(../function[name = $currentMethod/name]) != 1">
									<xsl:variable
										name="siblingChecks">

										<!-- check for other methods to be equal -->
										<xsl:for-each
											select="../function[name = $currentMethod/name]">
											<xsl:if
												test="$currentMethod != .">
												<xsl:element
													name="check">
													<xsl:choose>
														<xsl:when
															test="xbig:areTheseMethodsEqual($currentMethod, .,false()) and ./@virt != 'pure-virtual'">
															<xsl:value-of
																select="false()" />
														</xsl:when>
														<xsl:otherwise>
															<xsl:value-of
																select="true()" />
														</xsl:otherwise>
													</xsl:choose>
												</xsl:element>
											</xsl:if>
										</xsl:for-each>
									</xsl:variable>

									<!-- calc one result of all sibling checks -->
									<xsl:choose>
										<xsl:when
											test="$siblingChecks/* = true()">
											<xsl:value-of
												select="true()" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of
												select="false()" />
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>

								<!-- if there is no other method with the same name as the abstract one -->
								<xsl:otherwise>
									<xsl:value-of select="true()" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>

						<!-- if method is not abstract -->
						<xsl:otherwise>
							<xsl:value-of select="false()" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			</xsl:for-each>
		</xsl:variable>

		<!-- return true if there is at least one abstract method -->
		<xsl:choose>
			<xsl:when test="$allCheckResults/* = true()">
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>

	</xsl:function>



	<xd:doc type="function">
		<xd:short>
			As we filter a lot of methods with const parameters this template does some of the needed work.
			It copys the passed function element and removes const from parameters that are passed by value.
		</xd:short>
		<xd:param name="functionNode">function element to be processed.</xd:param>
	</xd:doc>
	<xsl:template
		name="copyFunctionAndRemoveConstFromByValuePassedParams">
		<xsl:param name="functionNode" />		
		
		<xsl:element name="function">
			<!-- copy all attributes -->
			<xsl:for-each select="$functionNode/@*">
				<xsl:copy-of select="." />
			</xsl:for-each>

			<!-- copy all children except parameters -->
			<xsl:for-each select="$functionNode/*">
				<xsl:if test="name() != 'parameters'">
					<xsl:copy-of select="." />
				</xsl:if>
			</xsl:for-each>

			<xsl:element name="parameters">
				<xsl:for-each
					select="$functionNode/parameters/parameter">
					<xsl:choose>
						<!-- change type of param -->
						<xsl:when
							test="./type/@const = 'true' and ./@passedBy= 'value'">
							<xsl:call-template
								name="copyParamAndSetConstFalse">
								<xsl:with-param name="paramNode"
									select="." />
							</xsl:call-template>
						</xsl:when>
						<!-- just copy param -->
						<xsl:otherwise>
							<xsl:copy-of select="." />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:element>
		</xsl:element>
	</xsl:template>


	<xd:doc type="function">
		<xd:short>
			As we filter a lot of methods with const parameters this template does some of the needed work.
			It copys the passed parameter element and sets const to false.
		</xd:short>
		<xd:param name="functionNode">function element to be processed.</xd:param>
	</xd:doc>
	<xsl:template name="copyParamAndSetConstFalse">
		<xsl:param name="paramNode" />

		<xsl:element name="parameter">
			<!-- copy all attributes -->
			<xsl:for-each select="$paramNode/@*">
				<xsl:copy-of select="." />
			</xsl:for-each>

			<!-- copy all children except type -->
			<xsl:for-each select="$paramNode/*">
				<xsl:if test="name() != 'type'">
					<xsl:copy-of select="." />
				</xsl:if>
			</xsl:for-each>

			<xsl:element name="type">
				<xsl:attribute name="const" select="'true'" />
				<xsl:value-of select="$paramNode/type" />
			</xsl:element>
		</xsl:element>
	</xsl:template>



	<xd:doc type="function">
		<xd:short>
			Returns true if the given function is a ctor. False otherwise.
		</xd:short>
		<xd:param name="class">The parent class node.</xd:param>
		<xd:param name="function">The function node to check.</xd:param>
	</xd:doc>
	<xsl:function name="xbig:isCtor" as="xs:boolean">
		<xsl:param name="class" />
		<xsl:param name="function" />
		<xsl:choose>
			<xsl:when test="$function/name = $class/@name">
				<!-- this is a ctor: skip it -->
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
</xsl:stylesheet>
