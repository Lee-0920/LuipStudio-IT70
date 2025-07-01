log = Log.Instance():GetLogger()

package.path = [[?;?.lua;?.ls;?;./SP/Common/?.ls;./SP/Setting/?.ls]]
require("Serialization")
require("Setting")
package.path = [[?;?.lua;?.ls;?;./SP/Common/?.ls;./SP/Setting/?.ls;./SP/Config/?.ls]]
require("ControlNetException")
require("MeasureFlowException")

--脚本文件夹所在路径
scriptsPath = "./SP"
require("ConfigLists")
require("ConfigModifyRecord")

--[[
 * @brief 标线XY进行调换。
 * @details 将标线模型mAbs=K*C+B转换成C=K*mAbs+B
 * @param[in] valueK 标线K值，或者表示变量X含义的字符串
 * @param[in] valueB 标线B值，或者表示变量Y含义的字符串
 * @return retK 转换后的标线K值，或者表示变量X含义的字符串
 * @return retB 转换后的标线B值，或者表示变量Y含义的字符串
--]]
function CurveParamCurveXYChange(valueK, valueB)
    local retK = valueK
    local retB = valueB

    if config.system.curveXYChange == false then
        -- 转换关闭,直接返回
        return retK, retB
    end

    if type(valueK) == "number" and type(valueK) == "number" then
        if valueK == 0 then
            retK = 0
            retB = 0
        else
            retK = 1 / valueK
            retB = (- valueB) / valueK
        end
        --print("valueK = " .. valueK .. " valueB = " .. valueB .. ", retK = " ..  retK .. " retB = " .. retB)
        return retK, retB
    end

    if type(valueK) == "string" and type(valueB) == "string" then
        if valueK == "C" then
            retK = "mAbs"
        end

        if valueB == "mAbs" then
            retB = "C"
        end
        --print("valueK = " .. valueK .. " valueB = " .. valueB .. ", retK = " ..  retK .. " retB = " .. retB)
        return retK, retB
    end
    --print("valueK = " .. valueK .. " valueB = " .. valueB .. ", retK = " ..  retK .. " retB = " .. retB)
    return retK, retB
end
