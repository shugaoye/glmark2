/*
 * Copyright © 2008 Ben Smith
 * Copyright © 2010-2011 Linaro Limited
 *
 * This file is part of the glmark2 OpenGL (ES) 2.0 benchmark.
 *
 * glmark2 is free software: you can redistribute it and/or modify it under the
 * terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * glmark2 is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * glmark2.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *  Ben Smith (original glmark benchmark)
 *  Alexandros Frantzis (glmark2)
 */
#include "scene.h"
#include "mat.h"
#include "stack.h"
#include "vec.h"
#include "log.h"
#include "shader-source.h"

#include <cmath>

SceneShading::SceneShading(Canvas &pCanvas) :
    Scene(pCanvas, "shading")
{
    mOptions["shading"] = Scene::Option("shading", "gouraud",
                                        "[gouraud, blinn-phong-inf, phong]");
}

SceneShading::~SceneShading()
{
}

int SceneShading::load()
{
    Model model;

    if(!model.load_3ds(GLMARK_DATA_PATH"/models/cat.3ds"))
        return 0;

    model.calculate_normals();

    /* Tell the converter that we only care about position and normal attributes */
    std::vector<std::pair<Model::AttribType, int> > attribs;
    attribs.push_back(std::pair<Model::AttribType, int>(Model::AttribTypePosition, 3));
    attribs.push_back(std::pair<Model::AttribType, int>(Model::AttribTypeNormal, 3));

    model.convert_to_mesh(mMesh, attribs);

    mMesh.build_vbo();

    mRotationSpeed = 36.0f;

    mRunning = false;

    return 1;
}

void SceneShading::unload()
{
    mMesh.reset();
}

void SceneShading::setup()
{
    Scene::setup();

    static const LibMatrix::vec4 lightPosition(20.0f, 20.0f, 10.0f, 1.0f);
    static const LibMatrix::vec4 materialDiffuse(0.0f, 0.0f, 1.0f, 1.0f);

    // Calculate half vector for blinn-phong shading model
    LibMatrix::vec3 halfVector(lightPosition[0], lightPosition[1], lightPosition[2]);
    halfVector.normalize();
    halfVector += LibMatrix::vec3(0.0, 0.0, 1.0);
    halfVector.normalize();

    std::string vtx_shader_filename;
    std::string frg_shader_filename;
    const std::string &shading = mOptions["shading"].value;

    if (shading == "gouraud") {
        vtx_shader_filename = GLMARK_DATA_PATH"/shaders/light-basic.vert";
        frg_shader_filename = GLMARK_DATA_PATH"/shaders/light-basic.frag";
    }
    else if (shading == "blinn-phong-inf") {
        vtx_shader_filename = GLMARK_DATA_PATH"/shaders/light-advanced.vert";
        frg_shader_filename = GLMARK_DATA_PATH"/shaders/light-advanced.frag";
    }
    else if (shading == "phong") {
        vtx_shader_filename = GLMARK_DATA_PATH"/shaders/light-phong.vert";
        frg_shader_filename = GLMARK_DATA_PATH"/shaders/light-phong.frag";
    }

    // Load shaders
    ShaderSource vtx_source(vtx_shader_filename);
    ShaderSource frg_source(frg_shader_filename);

    // Add constants to shaders
    vtx_source.add_const("LightSourcePosition", lightPosition);
    vtx_source.add_const("MaterialDiffuse", materialDiffuse);

    frg_source.add_const("LightSourcePosition", lightPosition);
    frg_source.add_const("LightSourceHalfVector", halfVector);

    if (!Scene::load_shaders_from_strings(mProgram, vtx_source.str(),
                                          frg_source.str()))
    {
        return;
    }

    mProgram.start();

    std::vector<GLint> attrib_locations;
    attrib_locations.push_back(mProgram["position"].location());
    attrib_locations.push_back(mProgram["normal"].location());
    mMesh.set_attrib_locations(attrib_locations);

    mCurrentFrame = 0;
    mRotation = 0.0f;
    mRunning = true;
    mStartTime = Scene::get_timestamp_us() / 1000000.0;
    mLastUpdateTime = mStartTime;
}

void SceneShading::teardown()
{
    mProgram.stop();
    mProgram.release();

    Scene::teardown();
}

void SceneShading::update()
{
    double current_time = Scene::get_timestamp_us() / 1000000.0;
    double dt = current_time - mLastUpdateTime;
    double elapsed_time = current_time - mStartTime;

    mLastUpdateTime = current_time;

    if (elapsed_time >= mDuration) {
        mAverageFPS = mCurrentFrame / elapsed_time;
        mRunning = false;
    }

    mRotation += mRotationSpeed * dt;

    mCurrentFrame++;
}

void SceneShading::draw()
{
    // Load the ModelViewProjectionMatrix uniform in the shader
    LibMatrix::Stack4 model_view;
    LibMatrix::mat4 model_view_proj(mCanvas.projection());

    model_view.translate(0.0f, 0.0f, -5.0f);
    model_view.rotate(mRotation, 0.0f, 1.0f, 0.0f);
    model_view_proj *= model_view.getCurrent();

    mProgram["ModelViewProjectionMatrix"] = model_view_proj;

    // Load the NormalMatrix uniform in the shader. The NormalMatrix is the
    // inverse transpose of the model view matrix.
    LibMatrix::mat4 normal_matrix(model_view.getCurrent());
    normal_matrix.inverse().transpose();
    mProgram["NormalMatrix"] = normal_matrix;

    // Load the modelview matrix itself
    mProgram["ModelViewMatrix"] = model_view.getCurrent();

    mMesh.render_vbo();
}

Scene::ValidationResult
SceneShading::validate()
{
    static const double radius_3d(std::sqrt(3.0));

    if (mRotation != 0) 
        return Scene::ValidationUnknown;

    Canvas::Pixel ref;

    Canvas::Pixel pixel = mCanvas.read_pixel(mCanvas.width() / 3,
                                             mCanvas.height() / 3);

    const std::string &filter = mOptions["shading"].value;

    if (filter == "gouraud")
        ref = Canvas::Pixel(0x00, 0x00, 0x2d, 0xff);
    else if (filter == "blinn-phong-inf")
        ref = Canvas::Pixel(0x1a, 0x1a, 0x3e, 0xff);
    else if (filter == "phong")
        ref = Canvas::Pixel(0x1a, 0x1a, 0x53, 0xff);
    else
        return Scene::ValidationUnknown;

    double dist = pixel_value_distance(pixel, ref);

    if (dist < radius_3d + 0.01) {
        return Scene::ValidationSuccess;
    }
    else {
        Log::debug("Validation failed! Expected: 0x%x Actual: 0x%x Distance: %f\n",
                    ref.to_le32(), pixel.to_le32(), dist);
        return Scene::ValidationFailure;
    }
}
