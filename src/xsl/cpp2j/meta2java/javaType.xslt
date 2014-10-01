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
	xmlns:xbig="http://xbig.sourceforge.net/XBiG"
	xmlns:str="http://exslt.org/strings">

	<xsl:import href="../../util/metaTypeInfo.xslt" />
	<xsl:import href="../../util/firstLetterToUpperCase.xslt" />
	<xsl:import href="../../util/createMetaParameterElement.xslt" />
	<xsl:import href="../../exslt/str.split.template.xsl" />

	<xd:doc type="stylesheet">
		<xd:short>Generate a single type.</xd:short>
	</xd:doc>

	<xd:doc type="template">
		<xd:short>
			Generates java types.
			Called for method parameters and return types. Can be used for public and native methods.
		</xd:short>
		<xd:param name="config">Config file.</xd:param>
		<xd:param name="param">
			Parameter or method element to be processed. Important are it's attributes.
		</xd:param>
		<xd:param name="class">Class which contains current type.</xd:param>
		<xd:param name="writingNativeMethod">
			True if a native method is generated. Type 'long' is often used then.
		</xd:param>
		<xd:param name="typeName">Already resolved and full qualified type name.</xd:param>
		<xd:param name="isTypeParameter">
			True if this type is a parameter of a Generic. Wrapper classes for primitve types are
			used in this case.
		</xd:param>
	</xd:doc>
	<xsl:template name="javaType">
		<xsl:param name="config" />
		<xsl:param name="param" />
		<xsl:param name="class" />
		<xsl:param name="writingNativeMethod" as="xs:boolean" />
		<xsl:param name="typeName" as="xs:string"/>
		<xsl:param name="isTypeParameter" as="xs:boolean" />

		<xsl:choose>
			<!-- if this type is a parametrized template -->
			<xsl:when test="contains($typeName, '&lt;')">
				<xsl:choose>
					<xsl:when test="$writingNativeMethod = false()">
						<xsl:sequence select="xbig:getFullJavaNameForParametrizedTemplate(
								$typeName, $config, $param, $class)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="'long'" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<!-- not a template -->
			<xsl:otherwise>

				<!-- resolve typedefs -->
				<xsl:variable name="resolvedType" select="xbig:resolveTypedef(
															$typeName, $class, $root)"/>

				<xsl:variable name="fullTypeName" select="$resolvedType"/>

				<!-- extract jni type depending on meta type, const/non-const, pass type -->
				<xsl:variable name="type_info">
					<xsl:call-template name="metaFirstTypeInfo">
						<xsl:with-param name="root" 
							select="$config/config/java/types" />
						<xsl:with-param name="param" select="$param" />
						<xsl:with-param name="typeName" select="$resolvedType" />
					</xsl:call-template>
				</xsl:variable>

				<!-- class used for pointer pointer -->
				<xsl:variable name="pointerPointerClass" select="'NativeObjectPointer'"/>

				<!-- DEBUG MESSAGES -->
				<!-- 
				<xsl:if test="$param/name() ne 'function' and starts-with($param/name,'c')">
					<xsl:message></xsl:message>
					<xsl:message>==== <xsl:value-of select="$param/name"/> ====</xsl:message>
					<xsl:message>Definition:           <xsl:value-of select="$param/definition"/></xsl:message>
					<xsl:message>Pointer or Reference: <xsl:value-of select="$param/@passedBy='pointer' or $param/@passedBy='reference'"/></xsl:message>
					<xsl:message>Const:                <xsl:value-of select="xbig:isTypeConst($param)"/></xsl:message>
					<xsl:message>Native:               <xsl:value-of select="boolean($writingNativeMethod)"/></xsl:message>
					<xsl:message>Primitive:            <xsl:value-of select="boolean($type_info/type/@java)"/></xsl:message>
				</xsl:if>
				 -->
				<!-- choose type -->
				<xsl:choose>
					<!-- write pointer class if the value is passed by pointer or reference and not const -->
					<xsl:when test="(($param/@passedBy='pointer' and not($resolvedType='char' and xbig:isTypeConst($param))) or
									($param/@passedBy='reference' and not(xbig:isTypeConst($param))))
									and ($writingNativeMethod ne true())
									and $type_info/type/@java">	
						<xsl:variable name="fullTypeNameWithPointer">
							<xsl:call-template name="javaPointerClass">
								<xsl:with-param name="config" select="$config" />
								<xsl:with-param name="param" select="$param" />
								<xsl:with-param name="typeName" select="$fullTypeName" />
							</xsl:call-template>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="$param/type/@pointerPointer = 'true'">
								<xsl:value-of select="concat(
										$pointerPointerClass, '&lt;', $fullTypeNameWithPointer, '&gt;')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$fullTypeNameWithPointer"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>

					<!-- if no type info is found -> we are dealing with a class / enum / ... -->
					<xsl:when test="not($type_info/type/@java)">
						<xsl:choose>

							<!-- template parameter used as method parameter or return type -->
							<xsl:when test="$class/templateparameters/templateparameter
											[@templateType='class' or @templateType='typename']
											[@templateDeclaration = $resolvedType]">
								<xsl:choose>
									<xsl:when test="$writingNativeMethod eq true()">
										<xsl:value-of select="'long'"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:choose>
											<xsl:when test="$param/type/@pointerPointer = 'true'">
												<xsl:value-of select="concat(
														$pointerPointerClass, '&lt;', $fullTypeName, '&gt;')"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="$fullTypeName"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>

							<!-- if this type is a template typedef -->
							<xsl:when test="xbig:isTemplateTypedef($fullTypeName, $class, $root)">
								<xsl:choose>
									<xsl:when test="$writingNativeMethod eq true()">
										<xsl:value-of select="'long'"/>
									</xsl:when>
									<xsl:otherwise>
										<!-- add the template angle bracket -->
										<xsl:variable name="fullJavaName" select="xbig:getFullJavaName(
																$fullTypeName, $class, $root, $config)"/>
										<xsl:choose>
											<xsl:when test="$param/type/@pointerPointer = 'true'">
												<xsl:value-of select="concat(
														$pointerPointerClass, '&lt;', $fullJavaName, '&gt;')"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="$fullJavaName"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>

							<!-- if this type is a template without type parameters,
								 e.g. Ogre::SharedPtr::operator=(SharedPtr) -->
							<xsl:when test="xbig:isTemplate($fullTypeName, $root)">
								<xsl:choose>
									<xsl:when test="$writingNativeMethod eq true()">
										<xsl:value-of select="'long'"/>
									</xsl:when>
									<xsl:otherwise>
										<!-- add the template angle bracket -->
										<xsl:variable name="fullJavaName" select="if
														($class/@originalTypedefFullName)
													then
														xbig:getFullJavaName(
														$class/@originalTypedefFullName,
														$class, $root, $config)
													else
														xbig:getFullJavaName(
														$class/@fullName,
														$class, $root, $config)"/>
										<xsl:choose>
											<xsl:when test="$param/type/@pointerPointer = 'true'">
												<xsl:value-of select="concat(
														$pointerPointerClass, '&lt;', $fullJavaName, '&gt;')"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="$fullJavaName"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>

							<!-- if this type is an enum -->
							<xsl:when test="xbig:isEnum($fullTypeName, $class, $root)">
								<xsl:choose>
									<xsl:when test="$writingNativeMethod eq true()">
										<xsl:value-of select="if ($param/@passedBy = 'pointer')
																then 'long'
																else 'int'"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:variable name="fullJavaName" select="
																xbig:getFullJavaClassAndNotInterfaceName(
																$fullTypeName, $class, $root, $config)"/>
										<xsl:choose>
											<xsl:when test="$param/type/@pointerPointer = 'true'">
												<xsl:value-of select="concat(
														$pointerPointerClass, '&lt;', $fullJavaName, '&gt;')"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="if ($param/@passedBy = 'pointer')
																		then concat('EnumPointer &lt; ',
																			$fullJavaName, ' &gt;')
																		else $fullJavaName"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>

							<!-- if this type is a class or struct -->
							<xsl:when test="xbig:isClassOrStruct($fullTypeName, $class, $root)">
								<xsl:choose>
									<xsl:when test="$writingNativeMethod eq true()">
										<xsl:value-of select="'long'"/>
									</xsl:when>
									<xsl:otherwise>
										<!-- This would be necessary for e.g. Ogre::Exception
											 and it's subclasses. But then we get a problem with
											 our interfaces (parameters must match exactly for
											 overriding). This could cause runtime errors.
										<xsl:variable name="fullJavaName" select="
														if ($param/../../name = 'operator=' or
															$param/../../name = 'operator =' and
															$class/inherits/baseClass/@fullBaseClassName
															 = $fullTypeName)
														then xbig:getFullJavaName(
															 $class/@fullName, $class, $root, $config)
														else xbig:getFullJavaName(
															 $fullTypeName, $class, $root, $config)"/>
										 -->
										<xsl:variable name="fullJavaName" select="xbig:getFullJavaName(
															 $fullTypeName, $class, $root, $config)"/>
										<xsl:choose>
											<xsl:when test="$param/type/@pointerPointer = 'true'">
												<xsl:value-of select="concat(
														$pointerPointerClass, '&lt;', $fullJavaName, '&gt;')"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="$fullJavaName"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>

							<!-- if this type is an enum constant -->
							<xsl:when test="xbig:isEnumConstant($fullTypeName, $class, $root)">
								<xsl:choose>
									<xsl:when test="$writingNativeMethod eq true()">
										<xsl:value-of select="if ($param/@passedBy = 'pointer')
																then 'long'
																else 'int'"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:variable name="fullJavaName" select="
																xbig:getFullJavaClassAndNotInterfaceName(
																xbig:getEnumTypeForEnumConstant($fullTypeName, $class, $root), $class, $root, $config)"/>
										<xsl:choose>
											<xsl:when test="$param/type/@pointerPointer = 'true'">
												<xsl:value-of select="concat(
														$pointerPointerClass, '&lt;', $fullJavaName, '&gt;')"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="if ($param/@passedBy = 'pointer')
																		then concat('EnumPointer &lt; ',
																			$fullJavaName, ' &gt;')
																		else $fullJavaName"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>

							<!-- if type is not found and a native method is generated -> use long -->
							<xsl:when test="$writingNativeMethod eq true()">
								<xsl:value-of select="'long'"/>
							</xsl:when>

							<xsl:otherwise>
								<xsl:variable name="fullJavaName" select="xbig:getFullJavaName(
											$fullTypeName, $class, $root, $config)"/>
								<xsl:choose>
									<xsl:when test="$param/type/@pointerPointer = 'true'">
										<xsl:value-of select="concat(
												$pointerPointerClass, '&lt;', $fullJavaName, '&gt;')"/>
									</xsl:when>
									<xsl:otherwise>
										<!-- Final else branch. -->
										<!-- Use general Object to avoid compiler errors. -->
										<!-- <xsl:value-of select="'Object'"/> -->
										<!-- Using Object makes it hard to find out what went wrong in generated code. -->
										<xsl:value-of select="$fullJavaName"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>

					<!-- types in config (usually primitive types) -->
					<xsl:otherwise>
						<xsl:choose>
							<!-- map const char* to String -->
							<!-- char* is handled somewhere above and should be 
							     a BytePointer or ShortPointer -->
							<xsl:when test="$param/@passedBy='pointer' and $resolvedType='char'">
								<xsl:value-of select="'String'"/>
							</xsl:when>
							<xsl:when test="$isTypeParameter = true()">
								<xsl:value-of select="$config/config/java/types/type
														[@meta = $resolvedType]/@genericParameter" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$type_info/type/@java" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>


	<xd:doc type="template">
		<xd:short>Helper template to generate pointer classes of primitive types.
		</xd:short>
		<xd:param name="config">config file.</xd:param>
		<xd:param name="param">
			parameter or method element to be processed. Important are it's attributes.
		</xd:param>
		<xd:param name="typeName">Already resolved and full qualified type name.</xd:param>
	</xd:doc>
	<xsl:template name="javaPointerClass">
		<xsl:param name="config" />
		<xsl:param name="param" />
		<xsl:param name="typeName" />

		<!-- extract jni type depending on meta type, const/non-const, pass type -->
		<xsl:variable name="type_info">
			<xsl:call-template name="metaFirstTypeInfo">
				<xsl:with-param name="root" 
					select="$config/config/java/types" />
				<xsl:with-param name="param" select="$param" />
				<xsl:with-param name="typeName" select="$typeName" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$type_info/type/@java != 'int' and
			                $type_info/type/@meta != 'std::wstring' and
			                $type_info/type/@meta != 'char'">
				<!-- <xsl:value-of> Usage error, must have select. -->
					<xsl:call-template name="firstLetterToUpperCase">
						<xsl:with-param name="name">
							<xsl:choose>
								<xsl:when test="contains($type_info/type/@java, ' ')">
									<xsl:value-of select="substring-after($type_info/type/@java, ' ')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$type_info/type/@java" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:value-of select="'Pointer'" />
				<!-- </xsl:value-of> -->
			</xsl:when>

			<!-- IntegerPointer is a special name -->
			<xsl:when test="$type_info/type/@java = 'int'">
				<xsl:value-of select="'IntegerPointer'" />
			</xsl:when>

			<!-- WideStringPointer is a special name, too -->
			<xsl:when test="$type_info/type/@meta = 'std::wstring'">
				<xsl:value-of select="'WideStringPointer'" />
			</xsl:when>

			<!-- char * (not const) -->
			<xsl:when test="$type_info/type/@meta = 'char'">
				<xsl:value-of select="'BytePointer'" />
			</xsl:when>
		</xsl:choose>

	</xsl:template>



	<xd:doc type="function">
		<xd:short>resolve the full java name of a type, including the package</xd:short>
		<xd:param name="type">Already resolved and full qualified type name.</xd:param>
		<xd:param name="currentNode">
			Meta namespace, class or struct element that contains this type.
		</xd:param>
		<xd:param name="inputTreeRoot">Root of input tree. Usually selected with '/'.</xd:param>
		<xd:param name="config">config file.</xd:param>
	</xd:doc>
	<xsl:function name="xbig:getFullJavaName" as="xs:string">
		<xsl:param name="type" as="xs:string"/>
		<xsl:param name="currentNode"/>
		<xsl:param name="inputTreeRoot"/>
		<xsl:param name="config"/>

		<xsl:variable name="javaTypeName">
			<xsl:variable name="typeWithoutGlobalNSPrefix">
				<xsl:choose>
					<xsl:when test="starts-with($type, '::')">
						<xsl:value-of select="substring-after($type, '::')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$type"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<!-- check if this is a primitive type -->
			<xsl:choose>
				<xsl:when test="$config/config/java/types/type[@meta = $typeWithoutGlobalNSPrefix]">
					<xsl:value-of select="$config/config/java/types/type
										  [@meta = $typeWithoutGlobalNSPrefix]/@java"/>
				</xsl:when>

				<!-- enums are not defined in interfaces -->
				<xsl:when test="xbig:isEnum($type, $currentNode, $inputTreeRoot)">
					<!-- 
					<xsl:variable name="fullNameAsReturned" select="xbig:getFullTypeName(
																$type, $currentNode, $inputTreeRoot)"/>
					 -->
					<xsl:variable name="fullNameAsReturned" select="$type"/>
					<xsl:variable name="nsPrefix"
									select="$config/config/java/namespaces/packageprefix"/>
					<xsl:variable name="fullNameWithDots"
							select="replace($fullNameAsReturned, '::', '.')"/>
					<xsl:value-of select="concat($nsPrefix, '.', $fullNameWithDots)"/>
				</xsl:when>

				<!-- classes, structs, typedefs, templates -->
				<xsl:otherwise>

					<!-- get full meta / c++ name -->
					<!-- 
					<xsl:variable name="fullNameAsReturned" select="xbig:getFullTypeName(
																$type, $currentNode, $inputTreeRoot)"/>
					 -->
					<xsl:variable name="fullNameAsReturned" select="$type"/>

					<!-- add java specific stuff to class name -->
					<xsl:variable name="fullNameTokens">
						<xsl:call-template name="str:split">
							<xsl:with-param name="string" select="$fullNameAsReturned" />
							<xsl:with-param name="pattern" select="'::'" />
						</xsl:call-template>
					</xsl:variable>

					<!-- for a little better performance -->
					<xsl:variable name="interfacePrefix" select="$config/config/java/interface/prefix"/>
					<xsl:variable name="interfaceSuffix" select="$config/config/java/interface/suffix"/>

					<xsl:variable name="nameFromHelper" select="xbig:getFullJavaNameHelper('', '', 0,
									$fullNameTokens, $inputTreeRoot, $interfacePrefix, $interfaceSuffix)"/>

					<xsl:choose>
						<xsl:when test="$nameFromHelper = ''">
							<xsl:value-of select="$type"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="nsPrefix"
									select="$config/config/java/namespaces/packageprefix"/>
							<xsl:variable name="fullNameWithDots"
									select="replace($nameFromHelper, '::', '.')"/>
							<xsl:value-of select="concat($nsPrefix, '.', $fullNameWithDots)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- return -->
		<xsl:value-of select="$javaTypeName"/>

	</xsl:function>


	<xd:doc type="function">
		<xd:short>Recursive helper function for getFullJavaName(). For internal usage.
				  It takes each part of a full name and adds interface stuff from config
				  if a part is a class or struct. So we get the right java name for inner classes.
		</xd:short>
		<xd:param name="currentJavaFullName">Already generated java name. Will be expanded</xd:param>
		<xd:param name="currentMetaFullName">
			Meta name of already processed type. Needed for selection.
		</xd:param>
		<xd:param name="currentPosition">Number of token which shall be processed during this call</xd:param>
		<xd:param name="fullNameTokens">Single parts of meta full name.</xd:param>
		<xd:param name="inputTreeRoot">Root of input tree. Usually selected with '/'.</xd:param>
		<xd:param name="interfacePrefix">
			from config file. Increases performance a little when passed.
		</xd:param>
		<xd:param name="interfaceSuffix">
			from config file. Increases performance a little when passed.
		</xd:param>
	</xd:doc>
	<xsl:function name="xbig:getFullJavaNameHelper" as="xs:string">
		<xsl:param name="currentJavaFullName" as="xs:string"/>
		<xsl:param name="currentMetaFullName" as="xs:string"/>
		<xsl:param name="currentPosition"/>
		<xsl:param name="fullNameTokens"/>
		<xsl:param name="inputTreeRoot"/>
		<xsl:param name="interfacePrefix"/>
		<xsl:param name="interfaceSuffix"/>

		<!-- this is ugly as hell, but this is also a very awful case, and it just has to work -->
		<xsl:variable name="breakToken" select="'#BREAKRECURSIONTOKEN#'"/>

		<!-- get current node -->
		<xsl:variable name="currentNode">
			<xsl:choose>
				<xsl:when test="$currentPosition = 0">
					<xsl:copy-of select="$inputTreeRoot/*/namespace[1]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="$inputTreeRoot//*[@fullName = $currentMetaFullName]"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- create first '::' in full name -->
		<xsl:variable name="currentMetaFullNameWithDot">
			<xsl:choose>
				<xsl:when test="$currentMetaFullName = ''">
					<xsl:value-of select="$currentMetaFullName"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($currentMetaFullName, '::')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- create first '.' in package name -->
		<xsl:variable name="currentJavaFullNameWithDot">
			<xsl:choose>
				<xsl:when test="$currentJavaFullName = ''">
					<xsl:value-of select="$currentJavaFullName"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($currentJavaFullName, '::')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- advance full name with next token -->
		<xsl:variable name="currentNameIncremented">
			<xsl:choose>

				<!-- classes -->
				<xsl:when test="$currentNode/*/class[@name = $fullNameTokens/*[$currentPosition+1]]">
					<xsl:value-of select="concat($currentJavaFullNameWithDot,
									$interfacePrefix,
									$fullNameTokens/*[$currentPosition+1],
									$interfaceSuffix)"/>
				</xsl:when>

				<!-- structs -->
				<xsl:when test="$currentNode/*/struct[@name = $fullNameTokens/*[$currentPosition+1]]">
					<xsl:value-of select="concat($currentJavaFullNameWithDot,
									$interfacePrefix,
									$fullNameTokens/*[$currentPosition+1],
									$interfaceSuffix)"/>
				</xsl:when>

				<!-- enums -->
				<xsl:when test="$currentNode/*/enumeration[@name = $fullNameTokens/*[$currentPosition+1]]">
					<xsl:value-of select="concat($currentJavaFullNameWithDot,
															$fullNameTokens/*[$currentPosition+1])"/>
				</xsl:when>

				<!-- namespaces -->
				<xsl:when test="$currentNode/*/namespace[@name = $fullNameTokens/*[$currentPosition+1]]">
					<xsl:value-of select="concat($currentJavaFullNameWithDot,
									xbig:getUnqualifiedJavaPackageName(concat(
									$currentMetaFullNameWithDot, $fullNameTokens/*[$currentPosition+1]),
									$config))"/>
				</xsl:when>

				<!-- typedefs for templates -> generated meta class -->
				<xsl:when test="$currentNode/*/typedef[@name = $fullNameTokens/*[$currentPosition+1]] and
								contains($currentNode/*/typedef
								[@name = $fullNameTokens/*[$currentPosition+1]]/@basetype, '&lt;')">
					<!-- TODO handle more than one inner class of the template this typedef is used for -->
					<xsl:variable name="fullNameOfBasetype" select="xbig:getFullTypeName(
										normalize-space(substring-before($currentNode/*/typedef
										[@name = $fullNameTokens/*[$currentPosition+1]]/@basetype, '&lt;'))
										, $currentNode/*, $inputTreeRoot)"/>
					<xsl:variable name="baseTypeNode"
										select="$inputTreeRoot//*[@fullName = $fullNameOfBasetype]"/>
					<xsl:choose>
						<!-- if this typedef is the last token -->
						<xsl:when test="count($fullNameTokens/*) = $currentPosition+1">
							<xsl:value-of select="concat($currentJavaFullNameWithDot,
									$interfacePrefix,
									$fullNameTokens/*[$currentPosition+1],
									$interfaceSuffix)"/>
						</xsl:when>

						<!-- template has inner class -->
						<xsl:when test="$baseTypeNode/class
										[@name = $fullNameTokens/*[$currentPosition+2]]">
							<xsl:value-of select="concat($currentJavaFullNameWithDot,
									$interfacePrefix,
									$fullNameTokens/*[$currentPosition+1],
									$interfaceSuffix,
									'::',
									$interfacePrefix,
									$fullNameTokens/*[$currentPosition+2],
									$interfaceSuffix,
									$breakToken)"/>
						</xsl:when>

						<!-- template has inner struct -->
						<xsl:when test="$baseTypeNode/struct
										[@name = $fullNameTokens/*[$currentPosition+2]]">
							<xsl:value-of select="concat($currentJavaFullNameWithDot,
									$interfacePrefix,
									$fullNameTokens/*[$currentPosition+1],
									$interfaceSuffix,
									'::',
									$interfacePrefix,
									$fullNameTokens/*[$currentPosition+2],
									$interfaceSuffix,
									$breakToken)"/>
						</xsl:when>

						<!-- template has inner enum -->
						<xsl:when test="$baseTypeNode/enumeration
											[@name = $fullNameTokens/*[$currentPosition+2]]">
							<xsl:value-of select="concat($currentJavaFullNameWithDot,
														$interfacePrefix,
														$fullNameTokens/*[$currentPosition+1],
														$interfaceSuffix,
														'::',
														$fullNameTokens/*[$currentPosition+2],
														$breakToken)"/>
						</xsl:when>

						<!-- nothing inner in template -->
						<xsl:otherwise>
							<xsl:value-of select="''"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>

				<!-- TODO typedefs for other stuff than templates -->

				<!-- invalid type -->
				<xsl:otherwise>
					<xsl:value-of select="''"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- return -->
		<xsl:choose>
			<!-- primitive types, invalid names, ... -->
			<xsl:when test="$currentNameIncremented = ''">
				<xsl:value-of select="''"/>
			</xsl:when>

			<!-- special case recursion end -->
			<xsl:when test="contains($currentNameIncremented, $breakToken)">
				<xsl:value-of select="substring-before($currentNameIncremented, $breakToken)"/>
			</xsl:when>

			<!-- recursion end -->
			<xsl:when test="count($fullNameTokens/*) = $currentPosition +1">
				<xsl:value-of select="$currentNameIncremented"/>
			</xsl:when>

			<!-- next recursion -->
			<xsl:otherwise>
				<xsl:variable name="metaNameIncrement" select="concat(
								$currentMetaFullNameWithDot, $fullNameTokens/*[$currentPosition+1])"/>
				<xsl:value-of select="xbig:getFullJavaNameHelper(
										$currentNameIncremented, $metaNameIncrement,
										$currentPosition+1, $fullNameTokens, $inputTreeRoot,
										$interfacePrefix, $interfaceSuffix)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>


	<xd:doc type="function">
		<xd:short>resolve the full java name of a type, 
					including the package but not of it's interface</xd:short>
		<xd:param name="type">Already resolved and full qualified type name.</xd:param>
		<xd:param name="currentNode">
			Meta namespace, class or struct element that contains this type.
		</xd:param>
		<xd:param name="inputTreeRoot">Root of input tree. Usually selected with '/'.</xd:param>
		<xd:param name="config">config file.</xd:param>
	</xd:doc>
	<xsl:function name="xbig:getFullJavaClassAndNotInterfaceName" as="xs:string">
		<xsl:param name="type" as="xs:string"/>
		<xsl:param name="currentNode"/>
		<xsl:param name="inputTreeRoot"/>
		<xsl:param name="config"/>

		<xsl:variable name="nsPrefix" select="$config/config/java/namespaces/packageprefix"/>
		<xsl:variable name="namespace" select="
					xbig:getNamespaceOfThatType('', $root, tokenize($type, '::'), 1)"/>
		<xsl:variable name="classes" select="substring-after($type, $namespace)"/>
		<xsl:value-of select="concat($nsPrefix, '.', xbig:getJavaPackageName(
									$namespace, $config), replace($classes, '::', '.'))"/>

	</xsl:function>



	<xd:doc type="function">
		<xd:short>
			Finds out which part of a full C++ name is the namespace (without classes).
		</xd:short>
		<xd:detail>
			Needed for renaming of C++ namespaces in Java. Parameter tokens contains full type name.
		</xd:detail>
		<xd:param name="namespace">Namespace to expand. Empty string ('') during first call.</xd:param>
		<xd:param name="inputTreeRoot">
			Root of input tree. Usually selected with '/'.
		</xd:param>
		<xd:param name="tokens">Parts of fullname. Splitted by '::'.</xd:param>
		<xd:param name="currentPosition">
			Number of token to be added to namespace. 1 during first call.
		</xd:param>
	</xd:doc>
	<xsl:function name="xbig:getNamespaceOfThatType" as="xs:string">
		<xsl:param name="namespace" as="xs:string"/>
		<xsl:param name="inputTreeRoot"/>
		<xsl:param name="tokens"/>
		<xsl:param name="currentPosition" as="xs:integer"/>

		<xsl:variable name="currentNamespace" select="if ($currentPosition = 1)
										then $tokens[1]
										else concat($namespace, '::', $tokens[$currentPosition])"/>
		<xsl:choose>
			<xsl:when test="$inputTreeRoot//*[@fullName = $currentNamespace]/name() = 'namespace'">
				<xsl:sequence select="xbig:getNamespaceOfThatType(
						$currentNamespace, $inputTreeRoot, $tokens, $currentPosition + 1)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="$namespace"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:function>


	<xd:doc type="function">
		<xd:short>
			Takes a type string which contains several '&lt;', '*', 'const' and other modifiers.
			Finds out correct type parameters (even parameters which are templates themselfs) and
			how they are passed (wether whole type is a pointer or just one parameter).
			Full java type is returned.
		</xd:short>
		<xd:param name="type">Type string to be parsed.</xd:param>
		<xd:param name="config">Config file.</xd:param>
		<xd:param name="param">
			Meta parameter element which contains this whole type. May be a parameter or a function.
		</xd:param>
		<xd:param name="class">
			Meta class element which contains function in which this type is used.
		</xd:param>
	</xd:doc>
	<xsl:function name="xbig:getFullJavaNameForParametrizedTemplate" as="xs:string">
		<xsl:param name="type" as="xs:string"/>
		<xsl:param name="config" />
		<xsl:param name="param" />
		<xsl:param name="class" />

		<!-- remember template it self -->	
		<xsl:variable name="resolvedBaseType" select="xbig:resolveTypedef(normalize-space(
												substring-before($type, '&lt;')), $class, $root)"/>
		<xsl:variable name="templateBaseType">

			<!-- 
			<xsl:call-template name="javaType">
				<xsl:with-param name="config" select="$config" />
				<xsl:with-param name="param" select="$param" />
				<xsl:with-param name="class" select="$class" />
				<xsl:with-param name="typeName" select="$resolvedBaseType" />
				<xsl:with-param name="writingNativeMethod" select="false()" />
				<xsl:with-param name="isTypeParameter" select="false()" />
			</xsl:call-template>
			 -->

			<xsl:sequence select="xbig:getFullJavaName($resolvedBaseType, $class, $root, $config)"/>
		</xsl:variable>

		<!-- get list of type parameters -->
		<xsl:variable name="tokens">
			<xsl:call-template name="xbig:getListOfTypeParameters">
				<xsl:with-param name="type" select="$type" />
			</xsl:call-template>
		</xsl:variable>

		<!-- get number of type parameters of base type (needed for optional type parameters) -->
		<xsl:variable name="numOfBaseTypeTypeParameters" as="xs:integer" select="
					count($root//*[@fullName = $resolvedBaseType]/templateparameters/templateparameter)"/>

		<!-- get java type for each type parameter -->
		<xsl:variable name="insideBracketResolved">
			<xsl:for-each select="$tokens/*">
				<xsl:if test="position() &lt;= $numOfBaseTypeTypeParameters">

					<xsl:variable name="paraElement">
						<xsl:call-template name="createMetaParameterElement">
							<xsl:with-param name="type" select="."/>
						</xsl:call-template>
					</xsl:variable>

					<xsl:choose>
						<!-- if type parameter is a template -->
						<xsl:when test="contains(., '&lt;')">
							<xsl:sequence select="xbig:getFullJavaNameForParametrizedTemplate(
												$paraElement/*[1]/type, $config, $paraElement, $class)"/>
						</xsl:when>

						<!-- type parameter is not a template -->
						<xsl:otherwise>
							<xsl:variable name="resolvedToken"
								select="xbig:resolveTypedef($paraElement/*[1]/type, $class, $root)"/>
							<xsl:call-template name="javaType">
								<xsl:with-param name="config" select="$config" />
								<xsl:with-param name="param" select="$paraElement/*[1]" />
								<xsl:with-param name="class" select="$class" />
								<xsl:with-param name="typeName" select="$resolvedToken"/>
								<xsl:with-param name="writingNativeMethod" select="false()" />
								<xsl:with-param name="isTypeParameter" select="true()" />
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>

					<!-- generate ',' between type parameters -->
					<xsl:if test="position() &lt; $numOfBaseTypeTypeParameters">
						<xsl:value-of select="', '"/>
					</xsl:if>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>

		<xsl:value-of select="concat($templateBaseType, '&lt; ', $insideBracketResolved, ' &gt;')"/>

	</xsl:function>


</xsl:stylesheet>
