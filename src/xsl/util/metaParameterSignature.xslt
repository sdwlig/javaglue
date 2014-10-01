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


	<xd:doc type="stylesheet">
		<xd:short>finds signature for single parameters.</xd:short>
	</xd:doc>

	<xd:doc type="template">
		<xd:short>Takes signature from config for primitive types. For other types, like classes,
				the typename is used. Not allowed characters like '::' or '&lt;' are masked with '_'.
				Pass type and constness are also taken into account.
		</xd:short>
		<xd:param name="config">config file.</xd:param>
		<xd:param name="param">parameter to be processed.</xd:param>
	</xd:doc>
	<xsl:template name="metaParameterSignature">
		<xsl:param name="config" />
		<xsl:param name="param" />

		<!-- ************************************************************ -->
		<!-- extract parameter values -->
		<!-- ************************************************************ -->

		<!-- shortcut for parameter type -->
		<xsl:variable name="param_type" select="type" />

		<!-- shortcut for const modifier -->
		<xsl:variable name="is_const" select="type/@const" />

		<!-- shortcut for array modifier -->
		<xsl:variable name="array_type" select="type/@array" />

		<!-- shortcut for passing type -->
		<xsl:variable name="pass_type"
			select="if($array_type) then 'array' else @passedBy" />

		<!-- shortcut for signatures -->
		<xsl:variable name="sigs"
			select="$config/config/meta/signatures" />

		<!-- ************************************************************ -->
		<!-- determine parameter signature -->
		<!-- ************************************************************ -->

		<!-- map type to signature with mapping table from configuration -->
		<xsl:variable name="type_signature">
			<xsl:choose>
				<xsl:when test="$sigs/type[@meta=$param_type]">
					<xsl:value-of select="$sigs/type[@meta=$param_type]/@signature"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="replace(replace(replace(replace(replace(replace(replace(
								$param_type, ' ', '_'), '::', '_'), '&lt;', '_'), '&gt;', '_'),
								 ',', '_'), '\*', 'ptr'), '&amp;', 'ref')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- ensure valid signature -->
		<xsl:if test="empty($type_signature)">
			<xsl:message terminate="yes">
				ERROR: no signature for parameter type '
				<xsl:value-of select="$param_type" />
				' found.
			</xsl:message>
		</xsl:if>

		<!-- ************************************************************ -->
		<!-- determine parameter passing signature -->
		<!-- ************************************************************ -->

		<!-- read signature for parameter passing method -->
		<xsl:variable name="pass_signature">
			<xsl:choose>
				<xsl:when test="$is_const eq 'true'">
					<xsl:value-of
						select="$sigs/const-pass[@meta=$pass_type]/@signature" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of
						select="$sigs/pass[@meta=$pass_type]/@signature" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- ensure valid parameter passing signature -->
		<xsl:if test="empty($pass_signature)">
			<xsl:message terminate="yes">
				ERROR: no signature for parameter passing type '
				<xsl:value-of select="$pass_type" />
				' found.
			</xsl:message>
		</xsl:if>

		<!-- ************************************************************ -->
		<!-- determine possible array signature -->
		<!-- ************************************************************ -->

		<xsl:variable name="array_signature"
			select="replace(replace(replace($array_type,'\]\[','_'),'\[',''),'\]','')" />

		<!-- ************************************************************ -->
		<!-- writing signature -->
		<!-- ************************************************************ -->

		<!-- write type signature -->
		<xsl:value-of select="$type_signature" />

		<!-- write parameter passing type -->
		<xsl:value-of select="$pass_signature" />

		<!-- write array signature -->
		<xsl:value-of select="$array_signature" />

	</xsl:template>


	<xd:doc type="function">
		<xd:short>Checks if given parameter has a name and returns it. 
					If it has no name, default name from config plus given position is returned.
		</xd:short>
		<xd:param name="param">
			Parameter node from meta.
		</xd:param>
		<xd:param name="pos">
			Parameter position (e.g. 1st parameter of function).
		</xd:param>
		<xd:param name="config">
			config.xml.
		</xd:param>
	</xd:doc>
	<xsl:function name="xbig:createParameterName">
		<xsl:param name="param" />
		<xsl:param name="pos" />
		<xsl:param name="config" />

		<xsl:choose>
				<xsl:when test="not($param/name) or $param/name = ''">
					<xsl:value-of
						select="concat(
									$config/config/meta/parameter/defaultName, $pos)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$param/name" />
				</xsl:otherwise>
			</xsl:choose>
	</xsl:function>

</xsl:stylesheet>
