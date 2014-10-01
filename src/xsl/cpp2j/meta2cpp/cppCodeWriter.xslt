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
	xmlns:xd="http://www.pnp-software.com/XSLTdoc"
	xmlns:xbig="http://xbig.sourceforge.net/XBiG"
	xmlns:str="http://exslt.org/strings">

	<xsl:import href="cppMethodDeclaration.xslt" />
	<xsl:import href="../../exslt/str.split.template.xsl" />

	<xd:doc type="stylesheet">
		<xd:short>
			Takes a source template from config and replaces the fields.
			With helper functions.
		</xd:short>
	</xd:doc>



	<!-- ************************************************************ -->
	<!-- xbig:cpp-param(config, param) -->
	<!-- ************************************************************ -->

	<xd:doc type="function">
		<xd:short>Gets variable names from config.</xd:short>
		<xd:param name="config">config file.</xd:param>
		<xd:param name="param">parameter to process.</xd:param>
	</xd:doc>
	<xsl:function name="xbig:cpp-param" as="xs:string">
		<xsl:param name="config" />
		<xsl:param name="param" as="xs:string" />

		<!-- shortcut for variable names configuration -->
		<xsl:variable name="cfg"
			select="$config/config/cpp/variables/cpp" />

		<xsl:value-of
			select="concat($cfg/prefix/@name, $param, $cfg/suffix/@name)" />

	</xsl:function>



	<!-- ************************************************************ -->
	<!-- xbig:cpp-type(config, param) -->
	<!-- ************************************************************ -->

	<xd:doc type="function">
		<xd:short>
			Gets C++ type to a meta type. Comparable with templates
			javaType or jniType.
		</xd:short>
		<xd:param name="config">config file.</xd:param>
		<xd:param name="param">parameter to process.</xd:param>
		<xd:param name="class">
			class which contains this type.
		</xd:param>
		<xd:param name="fullTypeName">
			Fully qualified type name.
		</xd:param>
		<xd:param name="isParameter">
			Indicates if this function call is for a c++ parameter or for a return type.
		</xd:param>
	</xd:doc>
	<xsl:function name="xbig:cpp-type" as="xs:string">
		<xsl:param name="config" />
		<xsl:param name="param" />
		<xsl:param name="class" />
		<xsl:param name="fullTypeName" />
		<xsl:param name="isParameter" as="xs:boolean" />

		<!-- shortcut to type conversion configurations -->
		<xsl:variable name="type_info">
			<xsl:call-template name="metaExactTypeInfo">
				<xsl:with-param name="root"
					select="$config/config/cpp/jni/types" />
				<xsl:with-param name="param" select="$param" />
				<xsl:with-param name="typeName" select="$fullTypeName" />
			</xsl:call-template>
		</xsl:variable>

		<!-- ensure valid signature -->
		<xsl:if test="count($type_info) != 1">
			<xsl:message terminate="yes">
				ERROR: no exact type info for meta type '
				<xsl:value-of select="$param/type" />
				' found.
			</xsl:message>
		</xsl:if>

		<!-- make cpp type const if it is const in meta.
		     But when type is a parameter and a string, it cannot be const
		     because to_stdstring changes passed out parameter.
		     String pointers are not converted with to_stdstring
		     and thus they may be const.
		     Return types must be const to avoid compiler errors. -->
		<xsl:variable name="isString" as="xs:boolean" select="$fullTypeName = 'std::string' or $fullTypeName = 'std::wstring'" />
		<xsl:variable name="const"
			select="if($param/type/@const eq 'true' and ($isParameter = false() or ($isString = true() and $param/@passedBy != 'pointer') = false())) then 'const ' else ''" />

		<!-- add '*' for pointer pointer -->
		<xsl:variable name="pointerPointer">
			<xsl:choose>
				<xsl:when test="$param/type/@pointerPointer = 'true'">
					<xsl:value-of select="'*'" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="''" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- <xsl:message>
		  fullTypeName: <xsl:value-of select="$fullTypeName" />
		  param/type: <xsl:value-of select="$param/type" />
		  @pointerPointer: <xsl:value-of select="$param/type/@pointerPointer" />
		  pointerPointer: <xsl:value-of select="$pointerPointer" />
		</xsl:message> -->

		<!-- if explicit conversion given -->
		<xsl:if test="$type_info/type/@cpp">
			<xsl:choose>
				<!-- see bug 1712709 -->
				<xsl:when
					test="$param/@passedBy = 'reference' and xbig:isTypeConst($param)">
					<xsl:value-of select="$fullTypeName" />
				</xsl:when>

				<!-- references need different conversion and return types -->
				<xsl:when
					test="$type_info/type/@pass='reference' and $param/definition">
					<xsl:value-of
						select="concat($const, $type_info/type/@returntype)" />
				</xsl:when>
				<xsl:otherwise>
					<!-- if const -->
					<!-- TODO check for const pointers (int* const) -->
					<!-- signed / unsigned char as pointer pointer, see bug 1728985 -->
					<xsl:variable name="constCppTypeFromConfig" select="$type_info/type[@const = 'true']/@cpp" />
					<xsl:variable name="nonConstCppTypeFromConfig" select="$type_info/type[@const = 'false' or not(@const)]/@cpp" />
					<xsl:variable name="cppTypeFromConfig" 
						select="if($param/type/@const = 'true') then 
									if($constCppTypeFromConfig) then
										$constCppTypeFromConfig
									else
										$type_info/type/@cpp
								else if($nonConstCppTypeFromConfig) then
									$nonConstCppTypeFromConfig
								else
									$type_info/type/@cpp" />
					<xsl:variable name="cppType" select="if($pointerPointer != '')
										then concat($fullTypeName, '*')
										else $cppTypeFromConfig"/>
					<!--
					<xsl:variable name="cppType" select="if(contains($fullTypeName, 'char')
										and $pointerPointer != '')
										then concat($fullTypeName, '*')
										else $cppTypeFromConfig"/>
					-->
					<!-- Return types are declared partly const always, see bug 1728998.
						 See Ogre::SceneNode::ConstObjectIterator::peekNextValuePtr.
					 -->
					<xsl:value-of select="if ($param//@constInTemplate = 'true'  and $param/name() = 'function')
									then concat('const ', $cppType, $const, $pointerPointer)
								else if ($param//@constInTemplate = 'true' 
									and $param/@passedBy != 'pointer')
									then concat($const, $cppType, $pointerPointer)
								else if ($param//@constInTemplate = 'true')
									then concat($cppType, $const, $pointerPointer)
								else
									concat($const, $cppType, $pointerPointer)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

		<!-- no explicit conversion given, compose from parameter information -->
		<xsl:if test="not($type_info/type/@cpp)">

			<xsl:variable name="type">
				<xsl:choose>
					<xsl:when test="not($param/type)">
						<xsl:value-of select="'void'" />
					</xsl:when>

					<xsl:when test="contains($fullTypeName, '&lt;')">
						<xsl:value-of
							select="concat(xbig:getFullTemplateName(
											$fullTypeName, $class, $root), '*')" />
					</xsl:when>

					<xsl:when
						test="xbig:isTemplateTypedef($fullTypeName, $class, $root)">
						<xsl:value-of
							select="concat($fullTypeName, '*')" />
					</xsl:when>
					<xsl:when
						test="xbig:isTemplate($fullTypeName, $root)">
						<xsl:value-of
							select="if($class/@originalTypedefFullName)
									then
										concat($class/@originalTypedefFullName, '*')
									else
										concat($class/@fullName, '*')" />
					</xsl:when>
					<xsl:when
						test="xbig:isClassOrStruct($fullTypeName, $class, $root)">
						<xsl:value-of
							select="if ($param/../../name = 'operator=' or 
										$param/../../name = 'operator ='
										and $class/inherits/baseClass/@fullBaseClassName = $fullTypeName)
									then concat($class/@fullName, '*')
									else concat($fullTypeName, '*')" />
					</xsl:when>
					<xsl:when
						test="xbig:isEnum($fullTypeName, $class, $root)">
						<xsl:value-of select="if ($param/@passedBy = 'pointer' or $param/@passedBy = 'reference')
									then concat($fullTypeName, '*')
									else $fullTypeName" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$fullTypeName" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="pass">
				<xsl:choose>
					<xsl:when
						test="$param/@passedBy eq 'pointer' and $type_info/type/@cpp">
						<xsl:text>*</xsl:text>
					</xsl:when>
					<xsl:when
						test="$param/@passedBy eq 'reference' and $type_info/type/@cpp">
						<xsl:text>&amp;</xsl:text>
					</xsl:when>
					<xsl:when test="$param/type/@array">
						<xsl:value-of select="$param/type/@array" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="''" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<!-- Return types are declared partly const always, see bug 1728998.
				 See Ogre::SceneNode::ConstObjectIterator::peekNextValuePtr.
			 -->
			<xsl:value-of select="if ($param//@constInTemplate = 'true' and $param/name() = 'function')
										then concat('const ', $type, $pass, $const, $pointerPointer)
									else if ($param//@constInTemplate = 'true' 
													and $param/@passedBy != 'pointer')
										then concat($const, $type, $pass, $pointerPointer)
									else if ($param//@constInTemplate = 'true')
										then concat($type, $pass, $const, $pointerPointer)
									else if ($pointerPointer != '' and $param/name() = 'function')
										then concat('const ', $type, $pass, ' const ', $pointerPointer)
									else if ($param/name() = 'function')
										then concat('const ', $type, $pass, $pointerPointer)
									else
										concat($const, $type, $pass, $pointerPointer)" />
		</xsl:if>

	</xsl:function>



	<!-- ************************************************************ -->
	<!-- xbig:jni-to-cpp(config, class, method, param) -->
	<!-- ************************************************************ -->

	<xd:doc type="function">
		<xd:short>
			Parameter conversion. Casts e.g. jlong to pointers.
		</xd:short>
		<xd:param name="config">config file.</xd:param>
		<xd:param name="class">
			class which contains this type.
		</xd:param>
		<xd:param name="method">
			method which contains this type.
		</xd:param>
		<xd:param name="param">parameter to process.</xd:param>
		<xd:param name="fullTypeName">
			Fully qualified type name.
		</xd:param>
		<xd:param name="param_name">
			Parameter name to be used. Should be created with xbig:createParameterName().
		</xd:param>
		<xd:param name="type_info">
			Info from meta about current type. Should be obtained with template 'metaExactTypeInfo'.
		</xd:param>
	</xd:doc>
	<xsl:function name="xbig:jni-to-cpp" as="xs:string">
		<xsl:param name="config" />
		<xsl:param name="class" />
		<xsl:param name="method" />
		<xsl:param name="param" />
		<xsl:param name="fullTypeName" />
		<xsl:param name="param_name" />
		<xsl:param name="type_info" />

		<!-- const or not, for a later concat -->
		<xsl:variable name="const"
			select="if($param/type/@const eq 'true') then ' const ' else ''" />

		<!-- find out if we have a pointer pointer pointer -->
		<xsl:variable name="pointerPointerAddOn">
			<xsl:choose>
				<xsl:when test="$param/type/@pointerPointer = 'true'">
					<xsl:value-of select="'*'" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="''" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- no conversion function available -->
		<xsl:if test="not($type_info/type/jni2cpp)">
			<xsl:choose>

				<!-- if this type is a parametrized template -->
				<xsl:when test="contains($fullTypeName, '&lt;')">

					<xsl:variable name="part1"
						select="'reinterpret_cast&lt; '" />
					<xsl:variable name="part2"
						select="xbig:getFullTemplateName(
												$fullTypeName, $class, $root)" />
					<xsl:variable name="part3"
						select="$pointerPointerAddOn" />
					<xsl:variable name="part4" select="if ($param//@constInTemplate = 'true')
														then '* const &gt;('
														else '* &gt;('" />
					<xsl:variable name="part5" select="$param_name" />
					<xsl:variable name="part6" select="')'" />
					<xsl:value-of select="if ($param//@constInTemplate = 'true')
						then concat($part1, $part2, $part3, $part4, $part5, $part6)
						else concat($part1, $const, $part2, $part3, $part4, $part5, $part6)" />
				</xsl:when>

				<!-- if this is a typedef for a template -->
				<xsl:when
					test="xbig:isTemplateTypedef($fullTypeName, $class, $root)">
					<xsl:variable name="part1"
						select="'reinterpret_cast&lt; '" />
					<xsl:variable name="part2" select="$fullTypeName" />
					<xsl:variable name="part3"
						select="$pointerPointerAddOn" />
					<xsl:variable name="part4" select="if ($param//@constInTemplate = 'true')
														then '* const &gt;('
														else '* &gt;('" />
					<xsl:variable name="part5" select="$param_name" />
					<xsl:variable name="part6" select="')'" />
					<xsl:value-of select="if ($param//@constInTemplate = 'true')
						then concat($part1, $part2, $part3, $part4, $part5, $part6)
						else concat($part1, $const, $part2, $part3, $part4, $part5, $part6)" />
				</xsl:when>

				<!-- if this type is a template without type parameter,
					 e.g. Ogre::SharedPtr::operator=(SharedPtr) -->
				<xsl:when
					test="xbig:isTemplate($fullTypeName, $root)">
					<xsl:variable name="part1"
						select="'reinterpret_cast&lt; '" />
					<xsl:variable name="part2" select="if($class/@originalTypedefFullName)
												then
													$class/@originalTypedefFullName
												else
													$class/@fullName" />
					<xsl:variable name="part3"
						select="$pointerPointerAddOn" />
					<xsl:variable name="part4" select="if ($param//@constInTemplate = 'true')
														then '* const &gt;('
														else '* &gt;('" />
					<xsl:variable name="part5" select="$param_name" />
					<xsl:variable name="part6" select="')'" />
					<xsl:value-of select="if ($param//@constInTemplate = 'true')
						then concat($part1, $part2, $part3, $part4, $part5, $part6)
						else concat($part1, $const, $part2, $part3, $part4, $part5, $part6)" />
				</xsl:when>

				<!-- test for enums -->
				<xsl:when
					test="xbig:isEnum($fullTypeName, $class, $root)">
					<xsl:value-of
						select="if ($param/@passedBy = 'pointer' or $param/@passedBy = 'reference')
						then concat('reinterpret_cast&lt; ', $fullTypeName, '* &gt;(', $param_name, ')') 
						else concat('(', $fullTypeName, ')', $param_name)" />
				</xsl:when>

				<!-- if this type is a class or struct -->
				<xsl:when
					test="xbig:isClassOrStruct($fullTypeName, $class, $root)">
					<xsl:variable name="part1"
						select="'reinterpret_cast&lt; '" />
					<xsl:variable name="part2" select="if ($method/name = 'operator=' or 
						  $method/name = 'operator =' and
						  $class/inherits/baseClass/@fullBaseClassName
						  = $fullTypeName)
						then $class/@fullName
						else $fullTypeName" />
					<xsl:variable name="part3"
						select="$pointerPointerAddOn" />
					<xsl:variable name="part4" select="if ($param//@constInTemplate = 'true')
										then '* const &gt;('
										else '* &gt;('" />
					<xsl:variable name="part5" select="$param_name" />
					<xsl:variable name="part6" select="')'" />
					<xsl:value-of select="if ($param//@constInTemplate = 'true')
						then concat($part1, $part2, $part3, $part4, $part5, $part6)
						else concat($part1, $const, $part2, $part3, $part4, $part5, $part6)" />
				</xsl:when>

				<xsl:otherwise>
					<xsl:value-of select="$param_name" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

		<!-- if conversion function available -->
		<xsl:if test="$type_info/type/jni2cpp">
			<xsl:choose>
				<!-- see bug 1712709 -->
				<xsl:when
					test="$param/@passedBy = 'reference' and xbig:isTypeConst($param)">
					<!-- TODO check if param name not set and use default value -->
					<xsl:choose>
						<xsl:when test="not($type_info/type/@const)">
							<xsl:value-of select="$param/name" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="code1"
								select="xbig:code(
								$config, xbig:removeCDATA($type_info/type[@const='true']/jni2cpp), $class, $method, '')" />
							<xsl:variable name="code2"
								select="replace($code1,'#jni_var#', $param_name)" />
							<xsl:value-of select="$code2" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>

				<!-- signed / unsigned char as pointer pointer, see bug 1728985 -->
				<xsl:when test="contains($fullTypeName, 'char') and $pointerPointerAddOn != ''">
					<xsl:value-of select="concat('(', $const, $fullTypeName, '*', 
								$pointerPointerAddOn, ')', '(',$param_name, ')')" />
				</xsl:when>

				<!-- the 'normal' way -->
				<xsl:otherwise>
					<!-- perform general code transformations -->
					<xsl:variable name="constConversionFromConfig" select="$type_info/type[@const = 'true']/jni2cpp"/>
					<xsl:variable name="nonConstConversionFromConfig" select="$type_info/type[@const = 'false' or not(./@const)]/jni2cpp"/>
					<xsl:variable name="conversionFromConfig" 
						select="if($param/type/@const = 'true') then 
									if($constConversionFromConfig) then
										$constConversionFromConfig
									else
										$type_info/type/jni2cpp
								else if($nonConstConversionFromConfig) then
									$nonConstConversionFromConfig
								else
									$type_info/type/jni2cpp" />
					<xsl:variable name="code1"
						select="xbig:code($config, xbig:removeCDATA($conversionFromConfig), $class, $method, '')" />

					<!-- add the pointer pointer '*' -->
					<xsl:variable name="code2"
						select="replace($code1, '[\*]', concat('*', $pointerPointerAddOn))" />

					<!-- replace parameter name in code fragment -->
					<xsl:variable name="code3"
						select="replace($code2,'#jni_var#', $param_name)" />

					<!-- write conversion code -->
					<xsl:value-of select="$code3" />

				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

	</xsl:function>



	<!-- ************************************************************ -->
	<!-- xbig:cpp-to-jni(config, class, method, param) -->
	<!-- ************************************************************ -->

	<xd:doc type="function">
		<xd:short>
			Return type conversion. Casts e.g. pointers to jlong.
		</xd:short>
		<xd:param name="config">config file.</xd:param>
		<xd:param name="class">
			class which contains this type.
		</xd:param>
		<xd:param name="method">
			method which contains this type.
		</xd:param>
		<xd:param name="param">parameter to process.</xd:param>
		<xd:param name="name">
			Parameter name. Needed for empty names in meta.
		</xd:param>
		<xd:param name="fullTypeName">
			Fully qualified type name.
		</xd:param>
	</xd:doc>
	<xsl:function name="xbig:cpp-to-jni" as="xs:string">
		<xsl:param name="config" />
		<xsl:param name="class" />
		<xsl:param name="method" />
		<xsl:param name="param" />
		<xsl:param name="name" />
		<xsl:param name="fullTypeName" />

		<!-- shortcut to type conversion configurations -->
		<xsl:variable name="type_info">
			<xsl:call-template name="metaExactTypeInfo">
				<xsl:with-param name="root"
					select="$config/config/cpp/jni/types" />
				<xsl:with-param name="param" select="$param" />
				<xsl:with-param name="typeName" select="$fullTypeName" />
			</xsl:call-template>
		</xsl:variable>

		<!-- shortcut for parameter name -->
		<xsl:variable name="param_name"
			select="if($name and not(empty($name))) then $name else $param/name" />

		<!-- no conversion function available -->
		<xsl:if test="not($type_info/type/cpp2jni)">

			<xsl:choose>
				<!-- if this type is a parametrized template -->
				<xsl:when test="contains($fullTypeName, '&lt;')">
					<xsl:variable name="returnCast">
						<xsl:value-of
							select="'reinterpret_cast&lt;jlong&gt;('" />
						<xsl:value-of select="$param_name" />
						<xsl:value-of select="')'" />
					</xsl:variable>
					<xsl:value-of select="$returnCast" />
				</xsl:when>

				<!-- if this is a typedef for a template -->
				<xsl:when
					test="xbig:isTemplateTypedef($fullTypeName, $class, $root)">
					<xsl:variable name="returnCast">
						<xsl:value-of
							select="'reinterpret_cast&lt;jlong&gt;('" />
						<xsl:value-of select="$param_name" />
						<xsl:value-of select="')'" />
					</xsl:variable>
					<xsl:value-of select="$returnCast" />
				</xsl:when>

				<!-- if this method returns an object -->
				<xsl:when
					test="xbig:isClassOrStruct($fullTypeName, $class, $root)">
					<xsl:variable name="returnCast">
						<xsl:value-of
							select="'reinterpret_cast&lt;jlong&gt;('" />
						<xsl:value-of select="$param_name" />
						<xsl:value-of select="')'" />
					</xsl:variable>
					<xsl:value-of select="$returnCast" />
				</xsl:when>

				<!-- if this method returns a pointer to an enum -->
				<xsl:when
					test="$param/@passedBy = 'pointer' and xbig:isEnum($fullTypeName, $class, $root)">
					<xsl:variable name="returnCast">
						<xsl:value-of
							select="'reinterpret_cast&lt;jlong&gt;('" />
						<xsl:value-of select="$param_name" />
						<xsl:value-of select="')'" />
					</xsl:variable>
					<xsl:value-of select="$returnCast" />
				</xsl:when>

				<xsl:otherwise>
					<xsl:value-of select="$param_name" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

		<!-- if conversion function available -->
		<xsl:if test="$type_info/type/cpp2jni">
			<xsl:choose>
				<!-- see bug 1712709 -->
				<xsl:when
					test="$param/@passedBy = 'reference' and xbig:isTypeConst($param)">
					<xsl:choose>
						<xsl:when test="not($type_info/type/@const)">
							<xsl:value-of
								select="$config/config/cpp/variables/cpp/result/@name" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="code1"
								select="xbig:code(
								$config, $type_info/type[@const='true']/cpp2jni, $class, $method, '')" />
							<xsl:variable name="code2"
								select="replace($code1,'#cpp_var#', $param_name)" />
							<xsl:value-of select="$code2" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>

				<!-- signed / unsigned char as pointer pointer, see bug 1728985 -->
				<xsl:when test="contains($fullTypeName, 'char') 
								and $param/type/@pointerPointer = 'true'">
					<!-- 
					<xsl:value-of select="concat('(', $const, $fullTypeName, '*', 
													$pointerPointerAddOn, ')',
												 '(',$param_name, ')')" />
												  -->
					<xsl:value-of select="concat('reinterpret_cast&lt;jlong&gt;(',$param_name,')')"/>
				</xsl:when>

				<!-- the 'normal way' -->
				<xsl:otherwise>
					<!-- perform general code transformations -->
					<xsl:variable name="constConversionFromConfig" select="$type_info/type[@const = 'true']/cpp2jni" />
					<xsl:variable name="nonConstConversionFromConfig" select="$type_info/type[@const = 'false' or not(@const)]/cpp2jni" />
					<xsl:variable name="conversionFromConfig" 
						select="if($param/type/@const = 'true') then
									if($constConversionFromConfig) then
										$constConversionFromConfig
									else
										$type_info/type/cpp2jni
								else if($nonConstConversionFromConfig) then
									$nonConstConversionFromConfig
								else
									$type_info/type/cpp2jni" />
					<xsl:variable name="code1"
						select="xbig:code($config, $conversionFromConfig, $class, $method, '')" />

					<!-- replace parameter name in code fragment -->
					<xsl:variable name="code2"
						select="replace($code1,'#cpp_var#', $param_name)" />

					<!-- write conversion code -->
					<xsl:value-of select="$code2" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

	</xsl:function>



	<!-- ************************************************************ -->
	<!-- xbig:cpp-replace(var, from, to) -->
	<!-- ************************************************************ -->

	<xd:doc type="function">
		<xd:short>
			Utility function to be used in this stylesheet.
		</xd:short>
		<xd:param name="var">Base string to search in.</xd:param>
		<xd:param name="from">String to search for.</xd:param>
		<xd:param name="to">String to replace.</xd:param>
	</xd:doc>
	<xsl:function name="xbig:cpp-replace" as="xs:string">
		<xsl:param name="var" as="xs:string" />
		<xsl:param name="from" as="xs:string" />
		<xsl:param name="to" as="xs:string" />

		<!-- prevent infinite recursion -->
		<xsl:choose>

			<xsl:when
				test="not(matches($to, $from)) and matches($var, $from)">
				<xsl:value-of select="replace($var, $from, $to)" />
			</xsl:when>

			<xsl:otherwise>
				<!-- return original value -->
				<xsl:value-of select="$var" />
			</xsl:otherwise>
		</xsl:choose>

	</xsl:function>



	<!-- ************************************************************ -->
	<!-- xbig:cpp-code(config, line, class, method) -->
	<!-- ************************************************************ -->

	<xd:doc type="function">
		<xd:short>
			Takes a code template and replaces the fields.
		</xd:short>
		<xd:param name="config">config file.</xd:param>
		<xd:param name="line" as="xs:string">code template.</xd:param>
		<xd:param name="class">
			class which contains this method.
		</xd:param>
		<xd:param name="method">method to be generated.</xd:param>
		<xd:param name="classPrefixForMethod">
			Full qualified class name with trailing '::' to put before method name or empty string ('').
		</xd:param>
	</xd:doc>
	<xsl:function name="xbig:code" as="xs:string">
		<xsl:param name="config" />
		<xsl:param name="line" />
		<xsl:param name="class" />
		<xsl:param name="method" />
		<xsl:param name="classPrefixForMethod" />

		<!-- shortcut for full class name -->
		<xsl:variable name="full_class_name" select="$class/@fullName" />

		<!-- shortcut for variable names configuration -->
		<xsl:variable name="var_config"
			select="$config/config/cpp/variables" />

		<!-- original code line -->
		<xsl:variable name="org_line" select="normalize-space($line)" />

		<!-- replace parameter conversions -->
		<!-- this was line7, has been moved here to allow more ##-variables in conversion -->
		<xsl:variable name="line-1">
			<xsl:choose>

				<xsl:when test="matches($org_line, '#cpp_conversions#')">
					<!-- write code for parameter conversion -->
					<xsl:variable name="param_conversions">
						<xsl:call-template
							name="cppMethodParameterConversion">
							<xsl:with-param name="config"
								select="$config" />
							<xsl:with-param name="class"
								select="$class" />
							<xsl:with-param name="method"
								select="$method" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:value-of
						select="xbig:cpp-replace($org_line, '#cpp_conversions#', $param_conversions)" />
				</xsl:when>

				<xsl:otherwise>
					<xsl:value-of select="$org_line" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- replace method name -->
		<xsl:variable name="line0">
			<!-- if const overloading is used, we have to find out the original name -->
			<xsl:choose>
				<xsl:when
					test="$method/@const = 'true' and not($class/function
						[name = c][@const = 'true'])">
					<!-- TODO test with prefix set -->
					<xsl:variable name="methodNameWithoutPrefix"
						select="substring-after(
						$method/name, $config/config/java/constoverloading/prefix)" />
					<xsl:variable name="suffix"
						select="$config/config/java/constoverloading/suffix" />
					<xsl:variable name="methodName">
						<xsl:choose>
							<xsl:when
								test="$suffix != '' and contains($methodNameWithoutPrefix, $suffix)">
								<xsl:value-of
									select="substring-before($methodNameWithoutPrefix, $suffix)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of
									select="$methodNameWithoutPrefix" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:value-of
						select="xbig:cpp-replace($line-1, '#cpp_method#', 
									concat($classPrefixForMethod, $methodName))" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of
						select="xbig:cpp-replace($line-1, '#cpp_method#', 
									concat($classPrefixForMethod, $method/name))" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- replace class name -->
		<xsl:variable name="line1">
			<xsl:choose>
				<!-- if we call a global method -->
				<xsl:when test="$class/@name = normalize-space($config/config/meta/globalmember/classNameForGlobalMember)">
					<xsl:variable name="namespace">
						<xsl:choose>
							<xsl:when test="$class/@name != $class/@fullName">
								<xsl:value-of select="substring($class/@fullName, 1, string-length($class/@fullName) - string-length($class/@name) - 2)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="''" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:choose>
						<!-- if we call a const method -->
						<xsl:when test="$method/@const = 'true'">
							<xsl:value-of
								select="xbig:cpp-replace($line0, '#cpp_class#', concat('const ', $namespace))" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of
								select="xbig:cpp-replace($line0, '#cpp_class#', $namespace)" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<!-- if we call a const method -->
						<xsl:when test="$method/@const = 'true'">
							<xsl:value-of
								select="xbig:cpp-replace($line0, '#cpp_class#', concat(
										'const ', $class/@fullName))" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of
								select="xbig:cpp-replace($line0, '#cpp_class#', $class/@fullName)" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>


		<!-- replace JNI environment variable -->
		<xsl:variable name="line2"
			select="xbig:cpp-replace($line1, '#jni_env#', $var_config/jni/environment/@name)" />

		<!-- replace JNI class variable -->
		<xsl:variable name="line3"
			select="xbig:cpp-replace($line2, '#jni_class#', $var_config/jni/class/@name)" />

		<!-- replace JNI object variable -->
		<xsl:variable name="line4"
			select="xbig:cpp-replace($line3, '#jni_object#', $var_config/jni/object/@name)" />

		<!-- replace JNI pointer variable -->
		<xsl:variable name="line5"
			select="xbig:cpp-replace($line4, '#jni_pointer#', $var_config/jni/pointer/@name)" />

		<!-- replace library pointer variable -->
		<xsl:variable name="line6"
			select="xbig:cpp-replace($line5, '#cpp_this#', $var_config/cpp/object/@name)">
		</xsl:variable>

		<!-- replace parameter conversions -->
		<!-- has been moved to top -->
		<xsl:variable name="line7" select="$line6" />

		<!-- resolve typedefs -->
		<xsl:variable name="resolvedType">
			<xsl:choose>
				<xsl:when test="not($method/type)">
					<xsl:value-of select="''" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of
						select="xbig:resolveTypedef($method/type, $class, $root)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="fullTypeName" select="$resolvedType" />

		<!-- replace parameter list -->
		<xsl:variable name="line8">
			<xsl:choose>

				<xsl:when test="matches($line7, '#cpp_params#')">
					<!-- write code for parameter conversion -->
					<xsl:variable name="params">
						<!-- iterate through all parameters for calling -->
						<xsl:for-each
							select="$method/parameters/parameter">

							<!-- resolve typedefs -->
							<xsl:variable name="resolvedParameter"
								select="xbig:resolveTypedef(
								./type, $class, $root)" />

							<xsl:variable name="fullParameterTypeName"
								select="$resolvedParameter" />

							<!-- References are casted to pointers and thus must be dereferenced. -->
							<!--
								        and $fullParameterTypeName != 'int'
								        and $fullParameterTypeName != 'unsigned int'
								        and $fullParameterTypeName != 'uint32_t'
								        and $fullParameterTypeName != 'int32_t'
								        and $fullParameterTypeName != 'uint16_t'
								        and $fullParameterTypeName != 'int16_t'
								        and $fullParameterTypeName != 'int8_t'
								        and $fullParameterTypeName != 'uint8_t'
								        and $fullParameterTypeName != 'int64_t'
								        and $fullParameterTypeName != 'uint64_t'
									and not(xbig:isEnum($fullParameterTypeName, $class, $root))
									...
									and @passedBy != 'reference'
							-->
							<xsl:if
								test="(@passedBy eq 'reference' and not(xbig:isTypeConst(.))
									and $fullParameterTypeName != 'unsigned char'
								        and $fullParameterTypeName != 'signed char'
								      )
							              or 
							              (
							              	@passedBy ne 'pointer'
							              	and
							                (
										      xbig:isClassOrStruct($fullParameterTypeName, $class, $root) 
										      or
										      xbig:isTemplateTypedef($fullParameterTypeName, $class, $root) 
										      or
										      contains(type, '&lt;')
										     )
										   )">
								<xsl:value-of select="'*'" />
							</xsl:if>

							<!-- if there is no param name in original lib -->
							<xsl:variable name="parameterPosition"
								select="position()" />
							<xsl:variable name="paramName">
								<xsl:choose>
									<xsl:when
										test="not(./name) or ./name = ''">
										<xsl:value-of
											select="concat(
														$config/config/meta/parameter/defaultName,
														$parameterPosition)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="./name" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>

							<!-- write parameter name -->
							<xsl:value-of
								select="xbig:cpp-param($config, $paramName)" />

							<!-- write seperator if neccessary -->
							<xsl:if test="position() != last()">
								<xsl:text>,&#32;</xsl:text>
							</xsl:if>

						</xsl:for-each>
					</xsl:variable>
					<xsl:value-of
						select="xbig:cpp-replace($line7, '#cpp_params#', $params)" />
				</xsl:when>

				<xsl:otherwise>
					<xsl:value-of select="$line7" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- replace return statement -->
		<xsl:variable name="line9"
			select="if(matches($line8, '#cpp_return#')) then xbig:cpp-replace(
				$line8, '#cpp_return#', xbig:cpp-to-jni(
				$config, $class, $method, $method, '#cpp_return_var#', $fullTypeName)) else $line8" />

		<!-- replace return type -->
		<xsl:variable name="line10"
			select="xbig:cpp-replace($line9, '#cpp_return_type#',
				xbig:cpp-type($config, $method, $class, $fullTypeName, false()))" />
		<!--
		<xsl:message> <method><xsl:copy-of select="$method"/> fullTypeName:<xsl:value-of select="$fullTypeName"/> </method>
		</xsl:message>
		-->

		<!-- replace class name -->
		<xsl:variable name="line11"
			select="xbig:cpp-replace($line10, '#cpp_return_var#', $var_config/cpp/result/@name)" />

		<!-- replace public attribute -->
		<xsl:variable name="line12">
			<xsl:choose>
				<xsl:when test="$method/attribute_name">
					<xsl:value-of
						select="xbig:cpp-replace(
										  $line11, '#cpp_attribute#', $method/attribute_name)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$line11" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- if an object is returned, we need it's address -->
		<xsl:variable name="line13">
			<xsl:variable name="searchFor"
				select="'#optional_return_conversion#'" />

			<xsl:variable name="replaceWith">
				<xsl:choose>
					<xsl:when test="not($method/type)">
						<xsl:value-of select="''" />
					</xsl:when>

					<xsl:when
						test="(xbig:isClassOrStruct($fullTypeName, $class, $root) or
									xbig:isTemplateTypedef($fullTypeName, $class, $root) or
									contains($method/type, '&lt;')
									) and $method/@passedBy != 'pointer'">
						<xsl:variable name="cppThis"
							select="$var_config/cpp/object/@name" />
						<xsl:choose>

							<!-- we have to move local objects to the heap -->
							<xsl:when
								test="$method/@passedBy = 'value' and
										not($method/@public_attribute_getter = 'true'
										 and $method/@static = 'true')">
								<xsl:value-of select="'new '" />
								<xsl:choose>
									<xsl:when
										test="contains($resolvedType, '&lt;')">
										<xsl:value-of
											select="xbig:getFullTemplateName(
															$fullTypeName, $class, $root)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of
											select="$fullTypeName" />
									</xsl:otherwise>
								</xsl:choose>
								<xsl:value-of select="'('" />
							</xsl:when>

							<xsl:when
								test="$method/@passedBy = 'value'">
								<xsl:text>&amp;</xsl:text>
							</xsl:when>

							<!-- passed by reference -->
							<xsl:otherwise>
								<xsl:value-of select="'&amp; '" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>

					<xsl:otherwise>
						<xsl:value-of select="''" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:value-of
				select="replace($line12, $searchFor, $replaceWith)" />
		</xsl:variable>

		<!-- create closing paranthesis -->
		<xsl:variable name="line14">
			<xsl:choose>
				<xsl:when test="not($method/type)">
					<xsl:value-of
						select="replace($line13, '#optional_closing_bracket#', '')" />
				</xsl:when>
				<xsl:when
					test="(xbig:isClassOrStruct($fullTypeName, $class, $root) or
								xbig:isTemplateTypedef($fullTypeName, $class, $root) or
								contains($method/type, '&lt;')
								) and $method/@passedBy = 'value' and not(
								 $method/@public_attribute_getter = 'true'
								 and $method/@static = 'true')">
					<xsl:value-of
						select="replace($line13, '#optional_closing_bracket#', ')')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of
						select="replace($line13, '#optional_closing_bracket#', '')" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>


		<xsl:variable name="result"
			select="xbig:cpp-replace(normalize-space($line14),'#nl#', $config/config/cpp/format/indent)" />

		<!-- real writing of code line -->
		<xsl:value-of select="$result" />
	</xsl:function>


</xsl:stylesheet>
